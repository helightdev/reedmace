import 'dart:convert';
import 'dart:io';

import 'package:cancellation_token/cancellation_token.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:reedmace_cli/command.dart';
import 'package:reedmace_cli/config.dart';
import 'package:path/path.dart' as path;
import 'package:reedmace_cli/utils/interruptable_progress.dart';

Future buildGeneratedClient(Logger logger, ReedmaceConfig config,
    {bool clean = false,
    bool throwOnFail = false,
    CancellationToken? cancellationToken}) async {
  getPathFromRoot(path.join(
      getPathFromRoot(config.structure.generatedClient).path,
      "lib",
      "api_specs.json"))
    ..createSync()
    ..writeAsString(readReedmaceCache("api_specs.json")!);
  getPathFromRoot(path.join(
      getPathFromRoot(config.structure.generatedClient).path,
      "lib",
      "mapping.json"))
    ..createSync()
    ..writeAsString(readReedmaceCache("mapping.json")!);
  await runBuildRunner(
      logger,
      getPathFromRoot(config.structure.generatedClient).path,
      "generated client",
      throwOnFail: throwOnFail,
      clean: clean,
      cancellationToken: cancellationToken);
}

Future<int> runBuildRunner(Logger logger, String path, String name,
    {bool clean = false,
    bool throwOnFail = false,
    CancellationToken? cancellationToken}) async {
  var action = BuildRunnerAction(logger, path, name, throwOnFail);
  cancellationToken?.attachCancellable(action);
  if (clean) await action.clean();
  return await action.run();
}

class BuildRunnerAction with Cancellable {
  Logger logger;
  String path;
  String name;
  bool throwOnFail = false;

  late InterruptibleProgress progress;

  BuildRunnerAction(this.logger, this.path, this.name, this.throwOnFail) {
    name = styleBold.wrap(name)!;
    progress = logger.interruptibleProgress("Building $name");
  }

  Process? _process;
  bool hasBeenCancelled = false;

  Future clean() async {
    progress.update("Cleaning build cache for $name");
    var cleanProcess = await Process.start(
        "flutter", ["pub", "run", "build_runner", "clean"],
        runInShell: true, workingDirectory: path);
    _process = cleanProcess;
    var cleanExitCode = await cleanProcess.exitCode;
    if (hasBeenCancelled) return;
    if (cleanExitCode != 0) {
      progress.fail("Failed to clean $name");
      if (throwOnFail) {
        throw "Failed to clean $name";
      } else {
        return cleanExitCode;
      }
    }
  }

  Future run() async {
    if (hasBeenCancelled) return;
    progress.update("Running build_runner for $name");
    var buildProcess = await Process.start("flutter",
        ["pub", "run", "build_runner", "build", "--delete-conflicting-outputs"],
        runInShell: true, workingDirectory: path);
    _process = buildProcess;
    StringBuffer errorOutput = StringBuffer();
    buildProcess.stdout.listen((event) {
      errorOutput.write(utf8.decode(event));
      progress.insert(() => logger.detail(utf8.decode(event).trim()));
    });
    buildProcess.stderr.listen((event) {
      errorOutput.write(utf8.decode(event));
    });
    var buildExitCode = await buildProcess.exitCode;
    if (hasBeenCancelled) return buildExitCode;
    if (buildExitCode != 0) {
      progress.fail("Failed to build $name");
      if (throwOnFail) {
        throw "Failed to build $name: ${errorOutput.toString()}";
      }
    } else {
      progress.complete("Built $name");
    }
    return buildExitCode;
  }

  @override
  void onCancel(Exception cancelException) {
    hasBeenCancelled = true;
    _process?.kill(ProcessSignal.sigkill);
    progress.cancel();
    super.onCancel(cancelException);
  }
}
