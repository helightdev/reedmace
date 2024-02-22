import 'dart:io';

import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf_io.dart' as io;

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
  await Future.any([
    ProcessSignal.sigterm.watch().first,
    ProcessSignal.sigint.watch().first
  ]);
  await server.close(force: true);
  print("Goodbye!");
  exit(0);
}
