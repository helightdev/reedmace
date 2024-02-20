import 'dart:convert';
import 'dart:async';

import 'package:reedmace/reedmace.dart';
import 'package:lyell/lyell.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../lib/reedmace.g.dart';
import '../lib/main.dart';

Future main() async {
  var reedmace = Reedmace();
  await reedmace.configure(configure);
  generatedRoutes.forEach(reedmace.registerRoute);
  await reedmaceBootstrap(reedmace);
}
