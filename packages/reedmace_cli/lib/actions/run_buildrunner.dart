import 'dart:convert';
import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:reedmace_cli/command.dart';
import 'package:reedmace_cli/config.dart';
import 'package:path/path.dart' as path;
import 'package:reedmace_cli/utils/interruptable_progress.dart';

Future buildGeneratedClient(Logger logger, ReedmaceConfig config,
    {bool clean = false, bool throwOnFail = false}) async {
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
      clean: clean);
}

Future<int> runBuildRunner(Logger logger, String path, String name,
    {bool clean = false, bool throwOnFail = false}) async {
  name = styleBold.wrap(name)!;
  var progress = logger.interruptibleProgress("Building $name");
  if (clean) {
    progress.update("Cleaning build cache for $name");
    var cleanProcess = await Process.start(
        "flutter", ["pub", "run", "build_runner", "clean"],
        runInShell: true, workingDirectory: path);
    var cleanExitCode = await cleanProcess.exitCode;
    if (cleanExitCode != 0) {
      progress.fail("Failed to clean $name");
      if (throwOnFail) {
        throw "Failed to clean $name";
      } else {
        return cleanExitCode;
      }
    }
  }
  progress.update("Running build_runner for $name");
  var process = await Process.start("flutter",
      ["pub", "run", "build_runner", "build", "--delete-conflicting-outputs"],
      runInShell: true, workingDirectory: path);
  StringBuffer errorOutput = StringBuffer();
  process.stdout.listen((event) {
    errorOutput.write(utf8.decode(event));
    progress.insert(() => logger.detail(utf8.decode(event).trim()));
  });
  process.stderr.listen((event) {
    errorOutput.write(utf8.decode(event));
  });
  var buildExitCode = await process.exitCode;
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
