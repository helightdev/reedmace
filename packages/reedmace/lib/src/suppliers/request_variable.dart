import 'package:conduit_open_api/v3.dart';
import 'package:recase/recase.dart';
import 'package:reedmace/reedmace.dart';

class RequestVariableArgumentSupplier extends ArgumentSupplier {
  @override
  ArgumentFactory? supply(
      MethodArgument argument, Reedmace reedmace, RouteDefinition definition) {
    var pathVariables = definition.routeAnnotation.pathVariables;
    if (pathVariables.contains(argument.name)) {
      var type = argument.type.typeArgument;
      return (context) => context.pathParams.get(argument.name);
    }
    if (argument.name == r"$catchall") {
      return (context) => context.pathParams.catchall.toList();
    }
    if (argument.name.startsWith(r"$$")) {
      var name = argument.name.substring(2).headerCase;
      return switch (argument.nullable) {
        true => (context) => context.request.headers[name],
        false => (context) {
            var header = context.request.headers[name];
            if (header == null) {
              throw HttpExceptions.badRequest("Missing required header $name");
            }
            return header;
          }
      };
    } else if (argument.name.startsWith(r"$")) {
      var name = argument.name.substring(1).snakeCase;
      return switch (argument.nullable) {
        true => (context) => context.queryParameters[name],
        false => (context) {
            var parameter = context.queryParameters[name];
            if (parameter == null) {
              throw HttpExceptions.badRequest(
                  "Missing required query parameter $name");
            }
            return parameter;
          }
      };
    }
    return null;
  }

  @override
  void modifyApiOperation(APIOperation operation, MethodArgument argument,
      Reedmace reedmace, RouteDefinition definition) {
    var pathVariables = definition.routeAnnotation.pathVariables;
    if (pathVariables.contains(argument.name)) {
      operation.addParameter(APIParameter.path(argument.name));
    } else if (argument.name.startsWith(r"$$")) {
      var name = argument.name.substring(2).headerCase;
      operation.addParameter(APIParameter.header(name,
          isRequired: !argument.nullable, schema: APISchemaObject.string()));
    } else if (argument.name.startsWith(r"$")) {
      var name = argument.name.substring(1).snakeCase;
      operation.addParameter(APIParameter.query(name,
          isRequired: !argument.nullable, schema: APISchemaObject.string()));
    }
  }
}
