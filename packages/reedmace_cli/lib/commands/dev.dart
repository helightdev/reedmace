import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mason_logger/mason_logger.dart';
import 'package:mutex/mutex.dart';
import 'package:reedmace_cli/actions/build_openapi.dart';
import 'package:reedmace_cli/actions/building_watcher.dart';
import 'package:reedmace_cli/actions/run_dev.dart';
import 'package:reedmace_cli/command.dart';
import 'package:reedmace_cli/commands/build.dart';
import 'package:reedmace_cli/config.dart';
import 'package:reedmace_cli/utils/interruptable_progress.dart';
import 'package:watcher/watcher.dart';

class ReedmaceDevCommand extends ReedmaceCommand {
  @override
  String get description => "Serve the application and watch for changes";

  @override
  String get name => "dev";

  @override
  Future<int> run() async {
    var runDevAction = RunDevAction(logger);
    await launchBuildingWatcherWithCallback(logger, config,(stage) {
      if (stage <= BuildStages.server) {
        runDevAction.enqueueRestart();
      }
    }, (stage) {
      if (stage <= BuildStages.server) {
        runDevAction.killAll();
      }
    }, (stage) {
      if (stage <= BuildStages.server) {
        runDevAction.killAll();
      }
    });
    await runDevAction.stop();
    return ExitCode.success.code;
  }
}
