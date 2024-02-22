import 'dart:convert';
import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:reedmace_cli/actions/build_openapi.dart';
import 'package:reedmace_cli/actions/run_buildrunner.dart';
import 'package:reedmace_cli/command.dart';
import 'package:reedmace_cli/config.dart';
import 'package:reedmace_cli/utils/interruptable_progress.dart';
import 'package:path/path.dart' as path;

class ReedmaceBuildCommand extends ReedmaceCommand {
  @override
  String get description => "Perform a build of the project";

  @override
  String get name => "build";

  ReedmaceBuildCommand() {
    argParser.addFlag("clean",
        abbr: "c",
        defaultsTo: false,
        help: "Clean the build cache before building");
  }

  @override
  Future<int> run() async {
    var config = readConfig();
    var isClean = argResults?["clean"] as bool;

    await runBuildRunner(logger, sharedLibraryDirectory.path, "shared library",
        clean: isClean, throwOnFail: true);
    await runBuildRunner(logger, serverDirectory.path, "server",
        clean: isClean, throwOnFail: true);
    await buildOpenapiDocumentProgress(logger);
    await buildGeneratedClient(logger, config,
        clean: isClean, throwOnFail: true);
    await runBuildRunner(logger, applicationDirectory.path, "application",
        clean: isClean, throwOnFail: true);

    return ExitCode.success.code;
  }
}
