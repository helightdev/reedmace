import 'package:conduit_open_api/v3.dart';
import 'package:recase/recase.dart';
import 'package:reedmace/reedmace.dart';

class QueryParamArgumentSupplier extends ArgumentSupplier {
  QueryParamArgumentSupplier() : super(120);

  @override
  ArgumentFactory? supply(
      MethodArgument argument, Reedmace reedmace, RouteDefinition definition) {
    if (argument.name.startsWith(r"$") && !argument.name.startsWith(r"$$")) {
      var name = argument.name.substring(1).snakeCase;
      return switch (argument.nullable) {
        true => nullable(argument, name),
        false => nonNullable(argument, name)
      };
    }
    return null;
  }

  ArgumentFactory nullable(MethodArgument argument, String name) {
    return switch (argument.type.typeArgument) {
      String => (context) => context.queryParameters[name],
      int => (context) {
          var parameter = context.queryParameters[name];
          if (parameter == null) return null;
          try {
            return int.parse(parameter);
          } catch (e) {
            throw HttpExceptions.badRequest(
                "Invalid value for query parameter $name: $parameter");
          }
        },
      bool => (context) {
          var parameter = context.queryParameters[name];
          if (parameter == null) return null;
          return parameter.toLowerCase() == "true" || parameter == "1";
        },
      _ => throw ArgumentError.value(argument, "argument",
          "Unsupported type for query parameter $name: ${argument.type.typeArgument}")
    };
  }

  ArgumentFactory nonNullable(MethodArgument argument, String name) {
    return switch (argument.type.typeArgument) {
      String => (context) {
          var parameter = context.queryParameters[name];
          if (parameter == null) {
            throw HttpExceptions.badRequest(
                "Missing required query parameter $name");
          }
          return parameter;
        },
      int => (context) {
          var parameter = context.queryParameters[name];
          if (parameter == null) {
            throw HttpExceptions.badRequest(
                "Missing required query parameter $name");
          }
          try {
            return int.parse(parameter);
          } catch (e) {
            throw HttpExceptions.badRequest(
                "Invalid value for query parameter $name: $parameter");
          }
        },
      bool => (context) {
          var parameter = context.queryParameters[name];
          if (parameter == null) {
            throw HttpExceptions.badRequest(
                "Missing required query parameter $name");
          }
          return parameter.toLowerCase() == "true" || parameter == "1";
        },
      _ => throw ArgumentError.value(argument, "argument",
          "Unsupported type for query parameter $name: ${argument.type.typeArgument}")
    };
  }

  @override
  void modifyApiOperation(APIOperation operation, MethodArgument argument,
      Reedmace reedmace, RouteDefinition definition) {
    if (argument.name.startsWith(r"$") && !argument.name.startsWith(r"$$")) {
      var name = argument.name.substring(1).snakeCase;
      operation.addParameter(APIParameter.query(name,
          isRequired: !argument.nullable,
          schema: switch (argument.type.typeArgument) {
            String => APISchemaObject.string(),
            int => APISchemaObject.integer(),
            bool => APISchemaObject.boolean(),
            _ => APISchemaObject.string(),
          }));
    }
  }
}
