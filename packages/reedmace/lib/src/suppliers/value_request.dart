import 'package:conduit_open_api/v3.dart';
import 'package:lyell/lyell.dart';
import 'package:reedmace/reedmace.dart';

class ValueReqArgumentSupplier extends ArgumentSupplier {
  ValueReqArgumentSupplier() : super(0);

  @override
  ArgumentFactory? supply(
      MethodArgument argument, Reedmace reedmace, RouteDefinition definition) {
    if (argument.type.base.typeArgument == ValReq) {
      var argumentTree = switch (argument.type.arguments.isEmpty) {
        true => QualifiedTypeTree.terminal<dynamic>(),
        false => argument.type.arguments[0] as QualifiedTypeTree
      };
      var bodySerializer =
          reedmace.sharedLibrary.resolveBodySerializer(argumentTree);
      if (bodySerializer == null) {
        throw ArgumentError(
            "No serializer found for request argument '${argument.name}'(${argumentTree.qualified})");
      }
      //print("Req '${argument.name}'@${definition.routeAnnotation.path}, serializer: $bodySerializer");
      return (context) async {
        var body = await bodySerializer.deserialize(context.request.read());
        return argumentTree
            .consumeTypeArg(ValReq.assemblerCreate, (context, body));
      };
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
        reedmace.sharedLibrary.resolveBodySerializer(argumentTree)!;
    operation.extensions["x-request-identifier"] = bodySerializer.identifier;
    if (bodySerializer.getSchema() == null) return;
    operation.requestBody = APIRequestBody.schema(
        contentTypes: [bodySerializer.descriptor.contentType],
        bodySerializer.getSchema() ?? APISchemaObject.freeForm());
  }
}
