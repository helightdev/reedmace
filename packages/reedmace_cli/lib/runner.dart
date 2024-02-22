import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:reedmace_cli/commands/build.dart';
import 'package:reedmace_cli/commands/create.dart';
import 'package:reedmace_cli/commands/dev.dart';
import 'package:reedmace_cli/commands/openapi.dart';
import 'package:reedmace_cli/commands/pub.dart';
import 'package:reedmace_cli/commands/watch.dart';
import 'package:reedmace_cli/config.dart';

class ReedmaceCommandRunner extends CommandRunner<int> {
  static late ReedmaceCommandRunner instance;

  late Logger logger;
  late bool failFast;
  bool failGlobal = false;

  ReedmaceConfig? _config;

  ReedmaceConfig get config => _config ??= readConfig();

  ReedmaceCommandRunner() : super("reedmace", "Reedmace CLI") {
    instance = this;
    logger = Logger();
    argParser.addFlag("verbose", abbr: "v", help: "Print verbose output");
    argParser.addFlag("fail-fast", help: "Stop on first error");
    addCommand(ReedmaceBuildCommand());
    addCommand(ReedmaceOpenapiCommand());
    addCommand(ReedmaceWatchCommand());
    addCommand(ReedmaceDevCommand());
    addCommand(ReedmacePubCommand());
    addCommand(ReedmaceCreateCommand());
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      var argResults = parse(args);
      if (argResults["verbose"] == true) {
        logger.level = Level.verbose;
      }
      failFast = argResults["fail-fast"] == true;
      return await runCommand(argResults) ?? ExitCode.success.code;
    } on FormatException catch (e) {
      logger
        ..err(e.message)
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    } catch (error) {
      logger.err('$error');
      return ExitCode.software.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    int? exitCode = ExitCode.unavailable.code;
    exitCode = await super.runCommand(topLevelResults);
    return exitCode;
  }
}
