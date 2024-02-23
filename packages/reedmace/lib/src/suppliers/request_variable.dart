import 'package:conduit_open_api/v3.dart';
import 'package:recase/recase.dart';
import 'package:reedmace/reedmace.dart';

class RequestVariableArgumentSupplier extends ArgumentSupplier {

  RequestVariableArgumentSupplier() : super(110);

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
    return null;
  }

  @override
  void modifyApiOperation(APIOperation operation, MethodArgument argument,
      Reedmace reedmace, RouteDefinition definition) {
    var pathVariables = definition.routeAnnotation.pathVariables;
    if (pathVariables.contains(argument.name)) {
      operation.addParameter(APIParameter.path(argument.name));
    }
  }
}
