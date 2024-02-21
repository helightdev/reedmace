import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  var projectDir = context.vars["projectName"].toString().snakeCase;
  await Process.run("dart", ["format", "."]);
  await Process.run("flutter", ["create", ".", "--platform", "android,ios,web", "--empty"], workingDirectory: "${projectDir}/app");
  await runReedmaceCommand(context, ["pub","-v"]);
  await runReedmaceCommand(context, ["build"]);
  context.logger.info("Project built successfully");
}

Future runReedmaceCommand(HookContext context, List<String> args) async {
  var projectDir = context.vars["projectName"].toString().snakeCase;
  var process = await Process.start("reedmace", args, workingDirectory: projectDir);
  process.stdout.listen((event) {
    stdout.add(event);
  });
  process.stderr.listen((event) {
    stderr.add(event);
  });
  await process.exitCode;
}