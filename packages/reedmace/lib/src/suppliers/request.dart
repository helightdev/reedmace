import 'package:conduit_open_api/v3.dart';
import 'package:lyell/lyell.dart';
import 'package:reedmace/reedmace.dart';

class ReqArgumentSupplier extends ArgumentSupplier {
  @override
  ArgumentFactory? supply(
      MethodArgument argument, Reedmace reedmace, RouteDefinition definition) {
    if (argument.type.base.typeArgument == Req) {
      var argumentTree = switch (argument.type.arguments.isEmpty) {
        true => QualifiedTypeTree.terminal<dynamic>(),
        false => argument.type.arguments[0] as QualifiedTypeTree
      };
      var bodySerializer =
          reedmace.sharedLibrary!.resolveBodySerializer(argumentTree);
      if (bodySerializer == null) {
        throw ArgumentError(
            "No serializer found for request argument '${argument.name}'(${argumentTree.qualified})");
      }
      //print("Req '${argument.name}'@${definition.routeAnnotation.path}, serializer: $bodySerializer");
      return (context) => argumentTree
          .consumeTypeArg(Req.assemblerCreate, (context, bodySerializer));
    }
    return null;
  }

  @override
  void modifyApiOperation(APIOperation operation, MethodArgument argument,
      Reedmace reedmace, RouteDefinition definition) {
    var argumentTree = switch (argument.type.arguments.isEmpty) {
      true => QualifiedTypeTree.terminal<dynamic>(),
      false => argument.type.arguments[0] as QualifiedTypeTree
    };
    var bodySerializer =
        reedmace.sharedLibrary!.resolveBodySerializer(argumentTree)!;
    operation.extensions["x-request-identifier"] = bodySerializer.identifier;
    if (bodySerializer.getSchema() == null) return;
    operation.requestBody = APIRequestBody.schema(
        contentTypes: [bodySerializer.descriptor.contentType],
        bodySerializer.getSchema() ?? APISchemaObject.freeForm());
  }
}
