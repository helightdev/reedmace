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
  }
}

class ReedmacePubGetCommand extends ReedmaceCommand {
  @override
  String get description => 'Run pub get in all packages';

  @override
  String get name => 'get';

  @override
  Future<int> run() async {
    await runPubGet(sharedLibraryDirectory);
    await runPubGet(serverDirectory);
    await runPubGet(generatedClientDirectory);
    await runPubGet(applicationDirectory);
    return ExitCode.success.code;
  }

  Future<void> runPubGet(Directory directory) async {
    var directoryName =
        directory.uri.pathSegments.where((element) => element.isNotEmpty).last;
    var progress = logger.interruptibleProgress(
        "Running pub get in ${styleBold.wrap(directoryName)}");
    var process = await Process.start("flutter", ["pub", "get"],
        workingDirectory: directory.path);
    process.stdout.listen((event) {
      progress.insert(() => logger.detail(utf8.decode(event).trim()));
    });
    process.stderr.listen((event) {
      progress.insert(() => logger.detail(utf8.decode(event).trim()));
    });

    var pubExitCode = await process.exitCode;
    if (pubExitCode != 0) {
      flagFailGlobal();
      progress.fail(
          "Failed to resolve dependencies for ${styleBold.wrap(directoryName)}");
    } else {
      progress.complete(
          "Finished resolving dependencies for ${styleBold.wrap(directoryName)}");
    }
  }
}
