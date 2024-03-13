import 'dart:async';

import 'package:mason_logger/mason_logger.dart';
import 'package:reedmace_cli/actions/building_watcher.dart';
import 'package:reedmace_cli/command.dart';

class ReedmaceWatchCommand extends ReedmaceCommand {
  @override
  String get description => "Watch for changes and rebuild the project";

  @override
  String get name => "watch";

  @override
  Future<int> run() async {
    await launchBuildingWatcher(logger, config);
    return ExitCode.success.code;
  }
}
