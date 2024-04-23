import 'dart:convert';

import 'package:lyell/lyell.dart';
import 'package:reedmace_client/reedmace_client.dart';

class ReedmaceClientMethod<T,SERIAL> {

  TypeCapture get serialType => TypeToken<SERIAL>();

  final String verb;
  final String path;
  final bool hasSchematicBody;
  final bool hasSchematicResponse;
  final TypeTree reqBodyType;
  final TypeTree resBodyType;

  const ReedmaceClientMethod(this.verb, this.path, this.hasSchematicBody,
      this.hasSchematicResponse, this.reqBodyType, this.resBodyType);

  Future<T?> send(ReedmaceClient client,
      {required Object? body,
        required Encoding? encoding,
        required Map<String, String> pathParameters,
        required Map<String, String> queryParameters,
        required Map<String, String> headerParameters}) async {
    var request = await client.createRequest(this,
        body: body,
        encoding: encoding,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        headerParameters: headerParameters);
    return await client.sendRequest(request, this) as T?;
  }

  ReedmaceClientMethodInvocation<T,SERIAL> createInvocation(
      {required ReedmaceClient client,
        required Object? body,
        required Encoding? encoding,
        required Map<String, String> pathParameters,
        required Map<String, String> queryParameters,
        required Map<String, String> headerParameters}) {
    return ReedmaceClientMethodInvocation(
      client: client,
      method: this,
      body: body,
      encoding: encoding,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      headerParameters: headerParameters,
    );
  }
}
