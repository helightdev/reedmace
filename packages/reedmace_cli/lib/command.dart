import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:reedmace_cli/config.dart';
import 'package:reedmace_cli/runner.dart';
import 'package:reedmace_cli/utils/common.dart';

export 'utils/common.dart';
export 'utils/interruptable_progress.dart';
export 'utils/styling.dart';

abstract class ReedmaceCommand extends Command<int> {

  Logger? _logger;
  ReedmaceCommandRunner? _runner;

  ReedmaceCommand({
    Logger? logger,
  }) : _logger = logger;



  Logger get logger => _logger ??= reedmaceRunner.logger;
  ReedmaceCommandRunner get reedmaceRunner => (runner as ReedmaceCommandRunner);

  ReedmaceConfig get config => reedmaceRunner.config;

  Directory get serverDirectory => Directory(getPathFromRoot(config.structure.server).path);
  Directory get sharedLibraryDirectory => Directory(getPathFromRoot(config.structure.sharedLibrary).path);
  Directory get generatedClientDirectory => Directory(getPathFromRoot(config.structure.generatedClient).path);
  Directory get applicationDirectory => Directory(getPathFromRoot(config.structure.application).path);

  void flagFailGlobal() {
    reedmaceRunner.failGlobal = true;
    if (reedmaceRunner.failFast) {
      exit(1);
    }
  }

}