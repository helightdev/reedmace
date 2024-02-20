import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:build/build.dart';
import 'package:conduit_open_api/v3.dart';
import 'package:path/path.dart' as path;
import 'package:reedmace_generator/reedmace_generator.dart';

class ClientPostProcessBuilder extends PostProcessBuilder {
  @override
  FutureOr<void> build(PostProcessBuildStep buildStep) async {
    var projectRoot = getNthParent(File(buildStep.inputId.path), 2);
    var entrypoint = projectRoot.path;

    buildStep.complete();
    return;

    var callbackPort = ReceivePort();
    var errorsPort = ReceivePort();
    var exitPort = ReceivePort();
    try {
      var isolate = await Isolate.spawnUri(
          Uri.file("$entrypoint/bin/api_document.dart"),
          [],
          callbackPort.sendPort,
          onError: errorsPort.sendPort,
          onExit: exitPort.sendPort);

      var result = await Future.any([callbackPort.first, exitPort.first, errorsPort.first.then((value) => ErrorWrapper(value))]);
      isolate.kill(priority: Isolate.immediate);

      if (result != null) {
        if (result is ErrorWrapper) {
          var (exception, stackTrace) = result.unwrap();
          log.severe("Error while running a dry server startup for route introspection", exception, stackTrace);
        } else {
          var str = result as String;

          var root = getNthParent(File(buildStep.inputId.path), 3);
          var reedmaceDir = Directory(path.join(root.path, ".reedmace"))
            ..createSync();
          File(path.join(reedmaceDir.path, "api_specs.json"))
            ..createSync()
            ..writeAsStringSync(str);
        }
      }
    } finally {
      exitPort.close();
      errorsPort.close();
      callbackPort.close();
      buildStep.complete();
    }
  }

  @override
  Iterable<String> get inputExtensions => ["reedmace.g.dart"];
}

class ErrorWrapper {
  final List message;

  ErrorWrapper(this.message);

  (Object,StackTrace) unwrap() {
    var [exception,stackTrace,...] = message;
    return (exception,StackTrace.fromString(stackTrace));
  }

  @override
  String toString() {
    var unwrapped = unwrap();
    return "${unwrapped.$1}:\n${unwrapped.$2}";
  }
}