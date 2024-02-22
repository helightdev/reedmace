import 'dart:io';

import 'package:mason/mason.dart';
import 'package:reedmace_cli/command.dart';

class ReedmaceCreateCommand extends ReedmaceCommand {
  @override
  String get description => 'Create a new Reedmace project.';

  @override
  String get name => 'create';

  ReedmaceCreateCommand() {
    argParser.addOption('name',
        abbr: 'n',
        defaultsTo: 'reedmace_project',
        help: 'The name of the project.');
  }

  @override
  Future<int> run() async {
    var projectName = styleBold.wrap(argResults!['name']);
    var progress = logger.progress("Creating project");
    final brick = Brick.git(
      const GitPath(
        'https://github.com/helightdev/reedmace',
        path: 'bricks/reedmace_project',
      ),
    );
    progress.update("Downloading brick");
    final generator = await MasonGenerator.fromBrick(brick);
    final target = DirectoryGeneratorTarget(Directory.current);
    var vars = <String, dynamic>{'projectName': argResults!['name']};
    progress.update("Generating project $projectName");
    await generator.generate(target, vars: vars, logger: logger);
    progress.update("Running post generation hooks");
    await generator.hooks.postGen(vars: vars);
    progress.complete("Project $projectName created!");
    return ExitCode.success.code;
  }
}
