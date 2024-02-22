import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:conduit_open_api/v3.dart';
import 'package:dart_style/dart_style.dart';
import 'package:lyell_gen/lyell_gen.dart';

class ClientBuilder extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    await tryInitialize(buildStep);

    var mappingData = await buildStep.readAsString(
        AssetId.resolve(Uri.parse("mapping.json"), from: buildStep.inputId));
    var apiSpecsData = await buildStep.readAsString(
        AssetId.resolve(Uri.parse("api_specs.json"), from: buildStep.inputId));

    var aliasCounter = AliasCounter();
    var cachedCounter = CachedAliasCounter(aliasCounter);
    var code = StringBuffer();
    var imports = <AliasImport>[
      AliasImport("dart:convert", null),
      AliasImport("package:dio/dio.dart", null),
      AliasImport("package:reedmace_client/reedmace_client.dart", null),
      AliasImport("package:http/http.dart", "http"),
      AliasImport.gen("package:lyell/lyell.dart"),
    ];
    var document = APIDocument.fromMap(jsonDecode(apiSpecsData));
    var opmodeEntries = document.paths!.values
        .expand((element) => element!.operations.entries)
        .toList();

    var futures = (jsonDecode(mappingData) as Map<String, dynamic>)
        .entries
        .map((entry) async {
      var takes = await deserializeType(entry.value[0], buildStep);
      var returns = await deserializeType(entry.value[1], buildStep);
      var operationId = entry.key;
      ;
      var resolvedOpmode = resolveOperationId(document, operationId);
      if (resolvedOpmode == null) {
        return;
      }
      var (path, verb, opmode) = resolvedOpmode;

      List<String> positionalParameters = [];
      List<String> namedParameters = [];
      List<String> pathParams = [];
      String encoding = "null";
      if (takes is! DynamicType) {
        positionalParameters.add("${cachedCounter.get(takes)} body");
      } else {
        namedParameters.add("dynamic body");
        namedParameters.add("Encoding? encoding");
        encoding = "encoding";
      }

      var bodyInserts = <String>[];
      for (var element in (opmode.parameters ?? <APIParameter?>[])) {
        if (element!.location == APIParameterLocation.path) {
          positionalParameters.add("String ${element.name}");
          pathParams.add(element.name!);
        }
        if (element.location == APIParameterLocation.query) {
          if (element.isRequired ?? true) {
            namedParameters.add("required String \$${element.name}");
            bodyInserts.add(
                "queryParameters['${sqsLiteralEscape(element.name!)}'] = \$${element.name};");
          } else {
            namedParameters.add("String? \$${element.name}");
            bodyInserts.add(
                "if (\$${element.name} != null) queryParameters['${sqsLiteralEscape(element.name!)}'] = \$${element.name};");
          }
        }
        if (element.location == APIParameterLocation.header) {
          if (element.isRequired ?? true) {
            namedParameters.add("required String \$\$${element.name}");
            bodyInserts.add(
                "headerParameters['${sqsLiteralEscape(element.name!)}'] = \$\$${element.name};");
          } else {
            namedParameters.add("String? \$\$${element.name}");
            bodyInserts.add(
                "if (\$\$${element.name} != null) headerParameters['${sqsLiteralEscape(element.name!)}'] = \$\$${element.name};");
          }
        }
      }

      var parts = [
        positionalParameters.join(","),
        namedParameters.isEmpty ? "" : "{${namedParameters.join(",")}}"
      ].where((element) => element.isNotEmpty).join(",");

      var pathInitializer = switch (pathParams.isEmpty) {
        true => "'${sqsLiteralEscape(path)}'",
        false =>
          "'${sqsLiteralEscape(path)}'.${pathParams.map((e) => "replaceFirst('{${sqsLiteralEscape(e)}}', $e)").join(".")}"
      };

      var returnType = switch (returns is DynamicType) {
        true => "Future<http.Response>",
        false => "Future<${cachedCounter.get(returns)}?>"
      };

      code.writeln("""
$returnType $operationId($parts) async {
  var path = $pathInitializer;
  var queryParameters = <String,String>{};
  var headerParameters = <String,String>{};
  ${bodyInserts.join("\n")}
  
  return ReedmaceClient.global.send<${cachedCounter.get(returns)}>('${sqsLiteralEscape(verb.toUpperCase())}', path,
  body: body,
  encoding: $encoding,
  hasBody: ${takes is DynamicType ? "false" : "true"},
  hasTypedResponse: ${returns is DynamicType ? "false" : "true"},
  reqBodyIdentifier: ${getTypeTree(takes).code(cachedCounter)}, 
  resBodyIdentifier: ${getTypeTree(returns).code(cachedCounter)}, 
  queryParameters: queryParameters, headerParameters: headerParameters)
  ${(returns is DynamicType) ? ".then((e) => e! as http.Response);" : ";"}
}
""");
    });
    await Future.wait(futures);

    var importString = createImports(
        library: null,
        id: null,
        imports: [...imports, ...cachedCounter.imports]);
    var finalContent = DartFormatter().format("$importString\n$code");
    buildStep.writeAsString(
        AssetId.resolve(buildStep.inputId.uri.resolve("client.g.dart")),
        finalContent);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        "\$lib\$": ["client.g.dart"]
      };
}

Directory getNthParent(File file, int n) {
  var parent = file.parent.absolute;
  for (var i = 0; i < n - 1; i++) {
    parent = parent.parent.absolute;
  }
  return parent;
}

(String path, String verb, APIOperation operation)? resolveOperationId(
    APIDocument document, String operationId) {
  var pathEntry = document.paths!.entries.firstWhereOrNull((element) => element
      .value!.operations.entries
      .any((element) => element.value!.id == operationId));
  if (pathEntry == null) return null;
  var opmodeEntry = pathEntry.value!.operations.entries
      .firstWhere((element) => element.value!.id == operationId);
  return (pathEntry.key, opmodeEntry.key, opmodeEntry.value!);
}
