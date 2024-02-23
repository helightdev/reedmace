import 'package:conduit_open_api/v3.dart';
import 'package:recase/recase.dart';
import 'package:reedmace/reedmace.dart';

class HeaderParamArgumentSupplier extends ArgumentSupplier {

  HeaderParamArgumentSupplier() : super(130);

  @override
  ArgumentFactory? supply(
      MethodArgument argument, Reedmace reedmace, RouteDefinition definition) {
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
    }
    return null;
  }

  @override
  void modifyApiOperation(APIOperation operation, MethodArgument argument,
      Reedmace reedmace, RouteDefinition definition) {
    if (argument.name.startsWith(r"$$")) {
      var name = argument.name.substring(2).headerCase;
      operation.addParameter(APIParameter.header(name,
          isRequired: !argument.nullable, schema: APISchemaObject.string()));
    }
  }
}
