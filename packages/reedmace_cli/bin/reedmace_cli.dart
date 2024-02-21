import 'dart:io';

import 'package:args/args.dart';
import 'package:reedmace_cli/command.dart';
import 'package:reedmace_cli/dogs.g.dart';
import 'package:reedmace_cli/runner.dart';

const String version = '0.0.1';

Future main(List<String> arguments) async {
  await initialiseDogs();
  var exitCode = await ReedmaceCommandRunner().run(arguments);
  await stdout.close();
  await stderr.close();
  if (ReedmaceCommandRunner.instance.failGlobal && exitCode == 0) {
    exitCode = 1;
  }
  exit(exitCode);
}
