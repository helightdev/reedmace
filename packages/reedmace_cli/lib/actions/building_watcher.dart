import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cancellation_token/cancellation_token.dart';
import 'package:canister/canister.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mutex/mutex.dart';
import 'package:reedmace_cli/actions/build_openapi.dart';
import 'package:reedmace_cli/actions/run_buildrunner.dart';
import 'package:reedmace_cli/command.dart';
import 'package:reedmace_cli/commands/build.dart';
import 'package:reedmace_cli/config.dart';
import 'package:reedmace_cli/utils/interruptable_progress.dart';
import 'package:watcher/watcher.dart';
import 'package:path/path.dart' as path;

Future launchBuildingWatcher(Logger logger, ReedmaceConfig config) async {
  var action = BuildingWatcherAction(logger, config);
  await action.launch();
}

Future launchBuildingWatcherWithCallback(Logger logger, ReedmaceConfig config,
    void Function(int) callback, void Function(int) startCallback, void Function(int) cancelCallback) async {
  var action = BuildingWatcherAction(logger, config);
  var subscription = action.buildController.stream.listen(callback);
  var startSubscription =
      action.buildStartController.stream.listen(startCallback);
  var cancelSubscription = action.cancelController.stream.listen(cancelCallback);
  await action.launch();
  await subscription.cancel();
  await startSubscription.cancel();
  await cancelSubscription.cancel();
}

class BuildStages {
  static const int sharedLibrary = 0;
  static const int server = 1;
  static const int application = 2;
}

class BuildingWatcherAction {

  ReedmaceConfig config;
  Logger logger;

  BuildingWatcherAction(this.logger, this.config);

  int? enqueuedBuild = 0;
  Mutex mutex = Mutex();
  String? latestApiDefHash;
  StreamController<int> buildController = StreamController<int>.broadcast();
  StreamController<int> buildStartController =
      StreamController<int>.broadcast();
  StreamController<int> cancelController = StreamController<int>.broadcast();
  
  Cache<String, String> hashCache = Cache.lru(50);

  bool debounceFileAction(String path) {
    var file = File(path);
    var fileHash = hashFile(file);
    var cacheHash = hashCache.get(file.path);
    if (fileHash == cacheHash) {
      return true;
    }
    hashCache.put(file.path, fileHash);
    return false;
  }

  bool watcherPathFilter(WatchEvent event) {
    if (event.path.endsWith(".dart") && !event.path.endsWith(".g.dart")) {
      if (debounceFileAction(event.path)) {
        return false;
      }
      logger.cln().detail("Detected change in ${event.path}");
      return true;
    }
    return false;
  }

  Future launch() async {
    var config = readConfig();

    var sharedLibraryWatcher = DirectoryWatcher(path.join(
            getPathFromRoot(config.structure.sharedLibrary).path, "lib"))
        .events
        .where(watcherPathFilter)
        .listen((event) => enqueueBuild(BuildStages.sharedLibrary));
    var serverWatcher = DirectoryWatcher(
            path.join(getPathFromRoot(config.structure.server).path, "lib"))
        .events
        .where(watcherPathFilter)
        .listen((event) => enqueueBuild(BuildStages.server));

    var applicationWatcher = DirectoryWatcher(path.join(
            getPathFromRoot(config.structure.application).path, "lib"))
        .events
        .where(watcherPathFilter)
        .listen((event) => enqueueBuild(BuildStages.application));

    stdin.echoMode = false;
    stdin.lineMode = false;
    var stdInListener = stdin.listen((event) {
      var str = utf8.decode(event);
      if (str == "r") {
        logger.cln().info("Forcing rebuild");
        enqueueBuild(0);
      }
    });

    enqueueBuild(0);
    await ProcessSignal.sigint.watch().first;
    stdin.echoMode = true;
    stdin.lineMode = true;
    logger.info("Exiting...");
    await sharedLibraryWatcher.cancel();
    await serverWatcher.cancel();
    await applicationWatcher.cancel();
    await stdInListener.cancel();
    await buildController.close();
    await buildStartController.close();
  }

  DateTime lastBuild = DateTime(2023);
  int currentBuild = -1;
  CancellationToken cancellationToken = CancellationToken();

  void enqueueBuild(int step) async {
    if (!mutex.isLocked) {
      lastBuild = DateTime.now();
      await mutex.protect(() async {
        enqueuedBuild = step;
        while (enqueuedBuild != null) {
          var nextStep = enqueuedBuild!;
          enqueuedBuild = null;
          currentBuild = nextStep;
          cancellationToken = CancellationToken();
          try {
            await performBuild(nextStep, cancellationToken);
          } catch (error, stack) {
            logger.cln().err("Failed to rebuild: $error\n$stack");
          }
        }
      });
      return;
    }

    if (DateTime.now().difference(lastBuild).inMilliseconds.abs() < 250) {
      return;
    }

    if (enqueuedBuild == null) {
      enqueuedBuild = step;
    } else {
      enqueuedBuild = min(step, enqueuedBuild!);
    }

    if (enqueuedBuild == currentBuild) {
      // Interrupt
      logger.cln().info("Interrupting build");
      cancelController.add(enqueuedBuild!);
      cancellationToken.cancel();
    }
  }

  bool checkYield(int step) {
    if (enqueuedBuild == null) return false;
    return enqueuedBuild! <= step;
  }

  Future performBuild(int stage, CancellationToken cancellationToken) {
    var scaffold = BuildScaffold(stage, this, cancellationToken);
    cancellationToken.attachCancellable(scaffold);
    return scaffold.run();
  }
}

class BuildScaffold with Cancellable {

  int stage;
  BuildingWatcherAction parent;
  CancellationToken cancellationToken;

  BuildScaffold(this.stage, this.parent, this.cancellationToken);

  bool hasBeenCancelled = false;

  Future run() async {
    parent.logger.detail("Starting build from $stage");
    parent.buildStartController.add(stage);
    var config = readConfig();
    if (stage <= BuildStages.sharedLibrary) {
      await runBuildRunner(
          parent.logger,
          getPathFromRoot(config.structure.sharedLibrary).path,
          "shared library",
          throwOnFail: true, cancellationToken: cancellationToken);
    }
    if (hasBeenCancelled) return; // Yield
    if (stage <= BuildStages.server) {
      await runBuildRunner(
          parent.logger, getPathFromRoot(config.structure.server).path, "server",
          throwOnFail: true, cancellationToken: cancellationToken);
      if (hasBeenCancelled) return; // Yield
      await buildOpenapiDocumentProgress(parent.logger);
    }
    if (hasBeenCancelled) return; // Yield
    var apiDefHash = currentApiDefHash;
    var hasApiChanged = parent.latestApiDefHash != apiDefHash;
    if (hasApiChanged) {
      await buildGeneratedClient(parent.logger, config, throwOnFail: true, cancellationToken: cancellationToken);
      parent.latestApiDefHash = apiDefHash;
    }
    if (hasBeenCancelled) return; // Yield
    if (stage <= BuildStages.application && hasApiChanged && (config.dev?.appBuildRunner ?? true)) {
      await runBuildRunner(parent.logger,
          getPathFromRoot(config.structure.application).path, "application",
          throwOnFail: true, cancellationToken: cancellationToken);
    }
    if (hasBeenCancelled) return; // Yield
    parent.logger.success("Completed build from $stage");
    parent.buildController.add(stage);
  }

  @override
  void onCancel(Exception cancelException) {
    hasBeenCancelled = true;
    super.onCancel(cancelException);
  }
}
