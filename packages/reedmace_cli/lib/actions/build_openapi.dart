import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:cancellation_token/cancellation_token.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:reedmace_cli/command.dart';
import 'package:reedmace_cli/config.dart';

Future buildOpenapiDocumentProgress(Logger logger, CancellationToken token) async {
  var progress = logger.progress("Building OpenAPI document");
  var result = await buildOpenapiDocument(token);
  if (result != null) {
    progress.fail(result);
  } else {
    progress.complete("OpenAPI document built");
  }
  return result;
}

Future<String?> buildOpenapiDocument(CancellationToken token) async {
  String? returnMessage;
  var config = readConfig();
  createReedmaceCache();
  var serverPath = getPathFromRoot(config.structure.server);
  var cachePath = getPathFromRoot(".reedmace");
  var apiDocEntrypoint = path.join(serverPath.path, "bin", "api_document.dart");
  var packageConfig =
      path.join(serverPath.path, ".dart_tool", "package_config.json");
  var jsonSpecEntry = path.join(cachePath.path, "api_specs.json");

  var callbackPort = ReceivePort();
  var errorsPort = ReceivePort();
  var exitPort = ReceivePort();
  try {
    var isolate = await Isolate.spawnUri(
      Uri.file(apiDocEntrypoint),
      [],
      callbackPort.sendPort,
      onError: errorsPort.sendPort,
      onExit: exitPort.sendPort,
      packageConfig: Uri.file(packageConfig),
    );

    var result = await Future.any([
      callbackPort.first,
      exitPort.first,
      errorsPort.first.then((value) => ErrorWrapper(value)),
      token.cancellation.then((value) => ErrorWrapper(["Cancelled",StackTrace.current])),
    ]);
    isolate.kill(priority: Isolate.immediate);

    if (result != null) {
      if (result is ErrorWrapper) {
        returnMessage = result.toString();
      } else {
        var str = result as String;

        File(jsonSpecEntry)
          ..createSync()
          ..writeAsStringSync(str);
      }
    }
  } finally {
    exitPort.close();
    errorsPort.close();
    callbackPort.close();
  }
  return returnMessage;
}

class ErrorWrapper {
  final List message;

  ErrorWrapper(this.message);

  (Object, StackTrace) unwrap() {
    var [exception, stackTrace, ...] = message;
    return (exception, StackTrace.fromString(stackTrace));
  }

  @override
  String toString() {
    var unwrapped = unwrap();
    return "${unwrapped.$1}:\n${unwrapped.$2}";
  }
}
