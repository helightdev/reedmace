import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:lyell/lyell.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:lyell_gen/src/subject.dart';
import 'package:reedmace/reedmace.dart';
import 'package:reedmace_generator/reedmace_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:uuid/uuid.dart';

class DefinitionBuilder extends SimpleAdapter<Route> {
  DefinitionBuilder() : super(archetype: "route");

  @override
  FutureOr<SubjectDescriptor> generateDescriptor(
      SubjectGenContext<Element> context) {
    var descriptor = context.defaultDescriptor();
    descriptor.meta["names"] = context.matches.map((e) => e.name).toList();
    descriptor.meta["build"] = Uuid().v4();

    var futureTypeChecker = TypeChecker.fromRuntime(Future);
    var reqChecker = TypeChecker.fromRuntime(Req);
    var resChecker = TypeChecker.fromRuntime(Res);

    var dataList = [];
    for (var element in context.matches) {
      if (element is! FunctionElement) {
        print("Not function element $element");
        continue;
      }
      var dataEntry = <String, dynamic>{};
      DartType resType;
      if (futureTypeChecker.isAssignableFromType(element.returnType)) {
        resType = (element.returnType as InterfaceType).typeArguments[0];
      } else {
        resType = element.returnType;
      }
      if (!resChecker.isAssignableFromType(resType)) {
        throw "Return type of ${element.name} must be a Res";
      }
      dataEntry["returns"] =
          serializeType((resType as InterfaceType).typeArguments[0]);

      var req = element.parameters.firstWhere(
          (element) => reqChecker.isAssignableFromType(element.type),
          orElse: () => throw "No Req parameter found for ${element.name}");

      dataEntry["takes"] = serializeType((req.type as InterfaceType).typeArguments[0]);
      dataEntry["operationId"] = element.name;

      print(dataEntry);
      dataList.add(dataEntry);
    }
    descriptor.meta["data"] = dataList;

    return descriptor;
  }

  @override
  FutureOr<void> generateSubject(SubjectGenContext<Element> genContext,
      SubjectCodeContext codeContext) async {
    if (genContext.matches.isEmpty) {
      print("No matches");
      codeContext.noGenerate = true;
      return;
    }
    await tryInitialize(genContext.step);

    codeContext.additionalImports.add(AliasImport("dart:async", null));
    codeContext.additionalImports
        .add(AliasImport.gen("package:lyell/lyell.dart"));
    codeContext.additionalImports
        .add(AliasImport.gen("package:reedmace/reedmace.dart"));

    for (var element in genContext.matches) {
      if (element is! FunctionElement) {
        print("Not function element $element");
        continue;
      }
      var retainedAnnotationChecker =
          TypeChecker.fromRuntime(RetainedAnnotation);
      var routeAnnotationChecker = TypeChecker.fromRuntime(Route);
      var routeAnnotation = routeAnnotationChecker.firstAnnotationOf(element)!;

      var parameters = element.parameters
          .map((e) =>
              "gen.MethodArgument(${getTypeTree(e.type).code(codeContext.cachedCounter)}, ${e.type.nullabilitySuffix != NullabilitySuffix.none},'${sqsLiteralEscape(e.name)}', [${e.metadata.whereTypeChecker(retainedAnnotationChecker).map((e) => codeContext.annotationSource(e)).join(",")}])")
          .toList();

      var futureTypeChecker = TypeChecker.fromRuntime(Future);
      var returnType =
          switch (futureTypeChecker.isAssignableFromType(element.returnType)) {
        true => (element.returnType as InterfaceType).typeArguments[0],
        false => element.returnType
      };

      var body = "gen.RouteDefinition('${sqsLiteralEscape(element.name)}',"
          "${codeContext.cachedCounter.toSource(routeAnnotation)},"
          "[${element.metadata.whereTypeChecker(retainedAnnotationChecker).map((e) => codeContext.annotationSource(e)).join(",")}],"
          "${getTypeTree(returnType).code(codeContext.cachedCounter)},"
          "[${parameters.join(",")}], _\$${element.name})";

      var libraryAlias =
          codeContext.cachedCounter.getLibraryAlias(element.library);
      codeContext.codeBuffer
          .writeln("const ${element.name}_descriptor = $body;");
      codeContext.codeBuffer.writeln(
          "FutureOr<${codeContext.typeName(returnType)}> _\$${element.name}(List<dynamic> args) => $libraryAlias.${element.name}(${parameters.map((e) => "args[${parameters.indexOf(e)}]").join(",")});");
    }
  }
}
