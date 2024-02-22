import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

Future launchBuildingWatcher(Logger logger) async {
  var action = BuildingWatcherAction(logger);
  await action.launch();
}

Future launchBuildingWatcherWithCallback(Logger logger,
    void Function(int) callback, void Function(int) startCallback) async {
  var action = BuildingWatcherAction(logger);
  var subscription = action.buildController.stream.listen(callback);
  var startSubscription =
      action.buildStartController.stream.listen(startCallback);
  await action.launch();
  await subscription.cancel();
  await startSubscription.cancel();
}

class BuildStages {
  static const int sharedLibrary = 0;
  static const int server = 1;
  static const int application = 2;
}

class BuildingWatcherAction {
  Logger logger;

  BuildingWatcherAction(this.logger);

  int? enqueuedBuild = 0;
  Mutex mutex = Mutex();
  String? latestApiDefHash;
  StreamController<int> buildController = StreamController<int>.broadcast();
  StreamController<int> buildStartController =
      StreamController<int>.broadcast();
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
      logger.detail("Detected change in ${event.path}");
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
        logger.info("Forcing rebuild");
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

  void enqueueBuild(int step) async {
    if (!mutex.isLocked) {
      lastBuild = DateTime.now();
      await mutex.protect(() async {
        enqueuedBuild = step;
        while (enqueuedBuild != null) {
          var nextStep = enqueuedBuild!;
          enqueuedBuild = null;
          try {
            await performBuild(nextStep);
          } catch (error, stack) {
            logger.err("Failed to rebuild: $error\n$stack");
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
  }

  bool checkYield(int step) {
    if (enqueuedBuild == null) return false;
    return enqueuedBuild! <= step;
  }

  Future performBuild(int stage) async {
    logger.detail("Starting build from $stage");
    buildStartController.add(stage);
    var config = readConfig();

    if (stage <= BuildStages.sharedLibrary) {
      await runBuildRunner(
          logger,
          getPathFromRoot(config.structure.sharedLibrary).path,
          "shared library",
          throwOnFail: true);
    }
    if (stage <= BuildStages.server) {
      await runBuildRunner(
          logger, getPathFromRoot(config.structure.server).path, "server",
          throwOnFail: true);
      await buildOpenapiDocumentProgress(logger);
    }

    var apiDefHash = currentApiDefHash;
    if (apiDefHash != latestApiDefHash) {
      await buildGeneratedClient(logger, config, throwOnFail: true);
      latestApiDefHash = apiDefHash;
    }

    if (stage <= BuildStages.application) {
      await runBuildRunner(logger,
          getPathFromRoot(config.structure.application).path, "application",
          throwOnFail: true);
    }

    logger.success("Completed build from $stage");
    buildController.add(stage);
  }
}
