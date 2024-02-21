import 'dart:io';

import 'package:mason/mason.dart';
import 'package:reedmace_cli/command.dart';

class ReedmaceCreateCommand extends ReedmaceCommand {

  @override
  String get description => 'Create a new Reedmace project.';

  @override
  String get name => 'create';

  ReedmaceCreateCommand() {
    argParser.addOption('name', abbr: 'n', defaultsTo: 'reedmace_project', help: 'The name of the project.');
  }

  @override
  Future<int> run() async {
    final brick = Brick.git(
      const GitPath(
        'https://github.com/helightdev/reedmace',
        path: 'bricks/reedmace_project',
      ),
    );
    final generator = await MasonGenerator.fromBrick(brick);
    final target = DirectoryGeneratorTarget(Directory.current);
    await generator.generate(target, vars: <String, dynamic>{'name': argResults!['name']}, logger: logger);
    return ExitCode.success.code;
  }

}