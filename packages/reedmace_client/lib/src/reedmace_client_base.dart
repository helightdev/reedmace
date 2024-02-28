import 'dart:async';
import 'dart:convert';

import 'package:lyell/lyell.dart';
import 'package:reedmace_client/src/future.dart';
import 'package:reedmace_shared/reedmace_shared.dart';
import 'package:http/http.dart' as http;

typedef RequestInterceptor = FutureOr<http.Request> Function(
    http.Request request);

class ReedmaceClientMethod<T> {
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

  ReedmaceClientMethodInvocation<T> createInvocation(
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

class ReedmaceClientMethodInvocation<T> with FutureMixin<T> {
  final ReedmaceClient client;
  final ReedmaceClientMethod<T> method;

  // Request Args
  final Object? body;
  final Encoding? encoding;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final Map<String, String> headerParameters;

  ReedmaceClientMethodInvocation({
    required this.client,
    required this.method,
    this.body,
    this.encoding,
    required this.pathParameters,
    required this.queryParameters,
    required this.headerParameters,
  });

  Future<T> exec() async {
    var value = await method.send(client,
        body: body,
        encoding: encoding,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        headerParameters: headerParameters);
    if (value == null) {
      throw HttpClientException(404, "Response was empty");
    }
    return value;
  }

  Future<T?> execOrNoContent() async {
    return await method.send(client,
        body: body,
        encoding: encoding,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  ReedmaceClientMethodInvocation copyWith({
    ReedmaceClient? client,
    ReedmaceClientMethod<T>? method,
    Object? body,
    Encoding? encoding,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Map<String, String>? headerParameters,
  }) {
    return ReedmaceClientMethodInvocation(
      client: client ?? this.client,
      method: method ?? this.method,
      body: body ?? this.body,
      encoding: encoding ?? this.encoding,
      pathParameters: pathParameters ?? this.pathParameters,
      queryParameters: queryParameters ?? this.queryParameters,
      headerParameters: headerParameters ?? this.headerParameters,
    );
  }

  Future<T>? _future;

  @override
  Future<T> get future => _future ??= exec();
}

class ReedmaceClient {
  static ReedmaceClient global = ReedmaceClient();

  static Future configure({
    required SharedLibrary sharedLibrary,
  }) async {
    global.sharedLibrary = sharedLibrary;
    await sharedLibrary.configure();
  }

  final http.Client httpClient = http.Client();
  SharedLibrary? sharedLibrary;

  Uri baseUri = Uri.http("localhost:8080");
  Map<String, String> defaultHeaders = {};
  List<RequestInterceptor> requestInterceptor = [];

  ReedmaceClient copyWith({
    http.Client? httpClient,
    SharedLibrary? sharedLibrary,
    Uri? baseUri,
    Map<String, String>? defaultHeaders,
    List<RequestInterceptor>? requestInterceptor,
    Map<String,String>? additionalHeaders,
    List<RequestInterceptor>? additionalRequestInterceptors,
  }) {
    return ReedmaceClient()
      ..sharedLibrary = sharedLibrary ?? this.sharedLibrary
      ..baseUri = baseUri ?? this.baseUri
      ..defaultHeaders = {...defaultHeaders ?? this.defaultHeaders, ...?additionalHeaders}
      ..requestInterceptor = [...requestInterceptor ?? this.requestInterceptor, ...?additionalRequestInterceptors];
  }

  Future<http.Request> createRequest(ReedmaceClientMethod method,
      {required Object? body,
      required Encoding? encoding,
      required Map<String, String> pathParameters,
      required Map<String, String> queryParameters,
      required Map<String, String> headerParameters}) async {
    var path = method.path;
    for (var entry in pathParameters.entries) {
      path = path.replaceFirst("{${entry.key}}", entry.value);
    }
    var uri = baseUri.resolve(path).replace(queryParameters: queryParameters);
    var reqBodySerializer = sharedLibrary!
        .resolveBodySerializer(method.reqBodyType as QualifiedTypeTree)!;
    var reqBodyEncoding = reqBodySerializer.descriptor.encoding;

    var request = http.Request(method.verb, uri);
    request.headers.addAll(defaultHeaders);
    request.headers.addAll(headerParameters);
    if (method.hasSchematicBody) {
      if (reqBodyEncoding != null) request.encoding = reqBodyEncoding;
      Object? encodedBody = reqBodySerializer.serialize(body);
      if (encodedBody is List<int>) {
        request.bodyBytes = encodedBody;
      } else if (encodedBody is String) {
        request.body = encodedBody;
      }
    } else {
      if (encoding != null) request.encoding = encoding;
      if (body is List<int>) {
        request.bodyBytes = body;
      } else if (body is String) {
        request.body = body;
      }
    }

    for (var interceptor in requestInterceptor) {
      request = await interceptor(request);
    }

    return request;
  }

  Future<Object?> sendRequest(
      http.Request request, ReedmaceClientMethod method) async {
    var resBodySerializer = sharedLibrary!
        .resolveBodySerializer(method.resBodyType as QualifiedTypeTree)!;

    var streamedResponse = await httpClient.send(request);

    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      throw HttpClientException(streamedResponse.statusCode,
          "Request failed with status code ${streamedResponse.reasonPhrase}");
    }

    if (method.hasSchematicResponse) {
      if (streamedResponse.statusCode == 204) {
        return null;
      }
      return await resBodySerializer.deserialize(streamedResponse.stream);
    } else {
      return await http.Response.fromStream(streamedResponse);
    }
  }
}

class HttpClientException implements Exception {
  final int statusCode;
  final String message;

  HttpClientException(this.statusCode, this.message);
}
