import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:canister/canister.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mutex/mutex.dart';
import 'package:reedmace_cli/command.dart';
import 'package:reedmace_cli/config.dart';
import 'package:path/path.dart' as path;

class RunDevAction {
  Logger logger;

  RunDevAction(this.logger);

  Mutex mutex = Mutex();
  List<Lazy<int>> processKillers = [];
  bool isEnqueued = false;

  void enqueueRestart() async {
    if (!mutex.isLocked) {
      await mutex.protect(() async {
        isEnqueued = true;
        while (isEnqueued) {
          isEnqueued = false;
          await killAll(true);
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

  Future<void> killAll([bool clear = false]) async {
    for (var killer in processKillers) {
      var success = await killer.value;
      logger.detail("Killed server: $success");
    }
    if (clear) processKillers.clear();
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

    while (processKillers.isNotEmpty) {
      await Future.delayed(Duration(milliseconds: 250));
    }

    var process = await Process.start(
      "flutter",
      ["pub", "run", (path.join(serverPath.path, "bin", "server.dart"))],
      workingDirectory: serverPath.path,
    );
    processKillers.add(getProcessKiller(process));
    var outDoneCompleter = Completer();
    process.stdout.listen((event) {
      var lines = utf8.decode(event).trim().split("\n");
      for (var line in lines) {
        logger.moduleInfo("Server", line);
      }
    }, onDone: outDoneCompleter.complete);
    process.stderr.listen((event) {
      logger.moduleErr("Server", utf8.decode(event).trim());
    });
    var exitCode = await process.exitCode;
    logger.detail("Server exited with code $exitCode");
    await outDoneCompleter.future;
    logger.detail("Server stdout closed");
  }
}

Lazy<int> getProcessKiller(Process process) => Lazy.by(() async {
      var exitFuture = process.exitCode;
      print("Killing server");
      // Send exit command to server since sometimes signals don't get through
      process.stdin.writeln("exit");
      process.stdin.flush();
      process.kill(ProcessSignal.sigterm);
      return await exitFuture;
    });
