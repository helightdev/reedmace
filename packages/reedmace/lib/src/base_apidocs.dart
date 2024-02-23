part of 'base.dart';

extension ApiDocExtension on Reedmace {
  APIDocument buildDocument() {
    var document = APIDocument();
    document.version = "3.0.0";
    document.info = APIInfo("Reedmace API", "0.0.1");
    document.paths = Map.of(router.apiRoutes).map((key, value) {
      var copiedMap = Map.of(value.verbs);
      copiedMap.remove("OPTIONS");
      copiedMap.remove("HEAD");

      var operationsMap = copiedMap.map((key, value) {
        return MapEntry(key, getOperation(value));
      });

      if (value.catchAll != null) {
        var freeVerbs = HttpVerb.getFreeVerbs(copiedMap);
        if (freeVerbs.isNotEmpty) {
          operationsMap[freeVerbs.first] = getOperation(value.catchAll!)
            ..extensions["x-verbs"] = freeVerbs;
        }
      }

      return MapEntry(key, APIPath(operations: operationsMap));
    })
      ..removeWhere((key, value) => value!.operations.isEmpty);
    document.components = APIComponents();
    for (var element in sharedLibrary.serializerModules) {
      element.contribute(document);
    }
    return document;
  }

  APIOperation getOperation(RouteRegistration registration) {
    var definition = registration.definition;
    var bodySerializer =
        sharedLibrary.resolveBodySerializer(definition.innerResponse)!;
    var response = switch (bodySerializer.identifier) {
      "none" => APIResponse.schema("success", APISchemaObject.freeForm()),
      _ => APIResponse.schema(
          "success",
          contentTypes: [bodySerializer.descriptor.contentType],
          bodySerializer.getSchema() ?? APISchemaObject.freeForm()),
    };

    var operation = APIOperation(definition.functionName, {
      "200": response,
    });

    operation.extensions["x-response-identifier"] = bodySerializer.identifier;

    for (var (i, supplier) in registration.assemblerSuppliers.indexed) {
      var argument = registration.definition.arguments[i];
      supplier.modifyApiOperation(operation, argument, this, definition);
    }
    return operation;
  }
}
