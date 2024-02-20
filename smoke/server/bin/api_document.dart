import 'dart:convert';
import 'dart:isolate';
import 'dart:async';

import 'package:reedmace/reedmace.dart';
import 'package:lyell/lyell.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../lib/reedmace.g.dart';
import '../lib/main.dart';

Future main(List<String> args, SendPort message) async {
  var reedmace = Reedmace();
  await reedmace.configure(configure);
  generatedRoutes.forEach(reedmace.registerRoute);
  message.send(jsonEncode(reedmace.buildDocument().asMap()));
}
