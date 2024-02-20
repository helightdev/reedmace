import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:reedmace_generator/reedmace_generator.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class ReedmaceReactorBuilder extends SubjectReactorBuilder {
  ReedmaceReactorBuilder() : super("reed", "reedmace.g.dart");

  late BuildStep _buildStep;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    _buildStep = buildStep;
    await super.build(buildStep);
  }

  @override
  FutureOr<void> buildReactor(
      List<SubjectDescriptor> descriptors, SubjectCodeContext code) async {
    code.additionalImports.add(AliasImport("dart:async", null));
    code.additionalImports.add(AliasImport.gen("package:lyell/lyell.dart"));
    code.additionalImports
        .add(AliasImport.gen("package:reedmace/reedmace.dart"));

    code.codeBuffer.writeln("""
    
     const String _incrementalBuildId = "${Uuid().v4()}";
    
const generatedRoutes = [${descriptors.expand((e) {
      var import = code.cachedCounter.getImportAlias(e.uri);
      return (e.meta["names"] as List)
          .map((e) => import.str("${e}_descriptor"));
    }).join(",")}];""");

    var maps = Map.fromEntries(descriptors.expand((element) => element.meta["data"] as List).map((e) {
      return MapEntry<String,dynamic>(e["operationId"], [e["takes"], e["returns"]]);
    }));

    var root = getNthParent(File(_buildStep.inputId.path), 3);
    var reedmaceDir = Directory(path.join(root.path, ".reedmace"))
      ..createSync();
    File(path.join(reedmaceDir.path, "mapping.json"))
      ..createSync()
      ..writeAsStringSync(jsonEncode(maps));

    createServerEntrypoint();

    //File("../api_client/lib/generated.dart").writeAsStringSync("final c = 'moin';");
  }

  void createServerEntrypoint() {
    Directory("bin").createSync();
    File("bin/server.dart")
      ..createSync()
      ..writeAsStringSync(DartFormatter().format("""    
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
    """));
    File("bin/api_document.dart")
      ..createSync()
      ..writeAsStringSync(DartFormatter().format("""    
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
    """));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
    r"$lib$": [reactorFileName]
  };
}
