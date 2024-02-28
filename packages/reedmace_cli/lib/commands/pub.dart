import 'dart:convert';
import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:reedmace_cli/command.dart';

class ReedmacePubCommand extends ReedmaceCommand {
  @override
  String get description => 'Pub related commands';

  @override
  String get name => 'pub';

  ReedmacePubCommand() {
    addSubcommand(ReedmacePubGetCommand());
    addSubcommand(ReedmacePubUpgradeCommand());
  }
}

class ReedmacePubGetCommand extends ReedmaceCommand {
  @override
  String get description => 'Run pub get in all packages';

  @override
  String get name => 'get';

  @override
  Future<int> run() async {
    await runPub(this, sharedLibraryDirectory, ["get"]);
    await runPub(this, serverDirectory, ["get"]);
    await runPub(this, generatedClientDirectory, ["get"]);
    await runPub(this, applicationDirectory, ["get"]);
    return ExitCode.success.code;
  }
}

class ReedmacePubUpgradeCommand extends ReedmaceCommand {
  @override
  String get description => 'Run pub upgrade in all packages';

  @override
  String get name => 'upgrade';

  @override
  Future<int> run() async {
    await runPub(this, sharedLibraryDirectory, ["upgrade"]);
    await runPub(this, serverDirectory, ["upgrade"]);
    await runPub(this, generatedClientDirectory, ["upgrade"]);
    await runPub(this, applicationDirectory, ["upgrade"]);
    return ExitCode.success.code;
  }
}

Future<void> runPub(ReedmaceCommand command, Directory directory, List<String> subcommand) async {
  var directoryName =
      directory.uri.pathSegments.where((element) => element.isNotEmpty).last;
  var progress = command.logger.interruptibleProgress(
      "Running ${subcommand.join(" ")} get in ${styleBold.wrap(directoryName)}");
  var process = await Process.start("flutter", ["pub", ...subcommand],
      workingDirectory: directory.path);
  process.stdout.listen((event) {
    progress.insert(() => command.logger.detail(utf8.decode(event).trim()));
  });
  process.stderr.listen((event) {
    progress.insert(() => command.logger.detail(utf8.decode(event).trim()));
  });

  var pubExitCode = await process.exitCode;
  if (pubExitCode != 0) {
    command.flagFailGlobal();
    progress.fail(
        "Failed to resolve dependencies for ${styleBold.wrap(directoryName)}");
  } else {
    progress.complete(
        "Finished resolving dependencies for ${styleBold.wrap(directoryName)}");
  }
}
