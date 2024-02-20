import 'dart:io';

import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf_io.dart' as io;

Future reedmaceBootstrap(Reedmace reedmace) async {
  var server = await io.serve(reedmace.handle, "localhost", 8080);
  print("Running on ${server.address.host}:${server.port}");
  await Future.any([ProcessSignal.sigterm.watch().first, ProcessSignal.sigint.watch().first]);
  await server.close(force: true);
  print("Goodbye!");
  exit(0);
}