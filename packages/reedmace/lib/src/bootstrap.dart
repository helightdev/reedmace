import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf_io.dart' as io;

final broadcastStdin = stdin.asBroadcastStream();

Future reedmaceBootstrap(Reedmace reedmace) async {
  print("Starting up reedmace server...");
  await reedmace.runStartupHooks();
  var configuration = reedmace.serverConfiguration;
  var server = await io.serve(
    reedmace.handler,
    configuration.address,
    configuration.port,
    backlog: configuration.backlog,
    shared: configuration.shared,
    securityContext: configuration.securityContext,
    poweredByHeader: configuration.poweredByHeader,
  );
  print("Running on ${server.address.host}:${server.port}");

  Completer<void> closeCompleter = Completer();
  void close([_]) => closeCompleter.complete();

  ProcessSignal.sigterm.watch().listen(close);
  ProcessSignal.sigint.watch().listen(close);
  broadcastStdin.firstWhere((element) {
    return utf8.decode(element).trim() == "exit";
  }).then(close);

  await closeCompleter.future;
  print("Shutting down...");
  await server.close(force: true);
  print("Goodbye!");
  exit(0);
}