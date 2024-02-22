import 'dart:convert';
import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:mutex/mutex.dart';
import 'package:reedmace_cli/command.dart';
import 'package:reedmace_cli/config.dart';
import 'package:path/path.dart' as path;

class RunDevAction {
  Logger logger;

  RunDevAction(this.logger);

  Mutex mutex = Mutex();
  List<Process> processes = [];
  bool isEnqueued = false;

  void enqueueRestart() async {
    if (!mutex.isLocked) {
      await mutex.protect(() async {
        isEnqueued = true;
        while (isEnqueued) {
          isEnqueued = false;
          await killAll();
          await Future.delayed(Duration(milliseconds: 50));
          await run();
        }
      });
      return;
    }

    logger.detail("Trying to restart server");
    isEnqueued = true;
    killAll();
  }

  Future<void> killAll() async {
    var waitForAllExit = Future.wait(processes.map((e) => e.exitCode));
    for (var process in processes) {
      var success = process.kill();
      logger.detail("Killing server: $success");
    }
    await waitForAllExit;
    processes.clear();
    logger.detail("All servers killed");
  }

  Future stop() async {
    isEnqueued = false;
    await killAll();
  }

  Future run() async {
    logger.detail("Starting server");
    var config = readConfig();
    var serverPath = getPathFromRoot(config.structure.server);

    while (processes.isNotEmpty) {
      await Future.delayed(Duration(milliseconds: 250));
    }

    var process = await Process.start(
      "flutter",
      ["pub", "run", (path.join(serverPath.path, "bin", "server.dart"))],
      workingDirectory: serverPath.path,
    );
    processes.add(process);
    process.stdout.listen((event) {
      var lines = utf8.decode(event).trim().split("\n");
      for (var line in lines) {
        logger.moduleInfo("Server", line);
      }
    });
    process.stderr.listen((event) {
      logger.moduleErr("Server", utf8.decode(event).trim());
    });
    var exitCode = await process.exitCode;
    logger.detail("Server exited with code $exitCode");
  }
}
