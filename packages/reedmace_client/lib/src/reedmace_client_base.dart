import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lyell/lyell.dart';
import 'package:reedmace_shared/reedmace_shared.dart';
import 'package:http/http.dart' as http;

typedef RequestInterceptor = FutureOr<http.Request> Function(http.Request request);

class ReedmaceClient {
  static ReedmaceClient global = ReedmaceClient();

  static Future configure({
    required SharedLibrary sharedLibrary,
  }) async {
    global.sharedLibrary = sharedLibrary;
    await sharedLibrary.configure();
  }

  final List<ReedmaceSerializerModule> serializerModules = [
    DefaultReedmaceModule()
  ];
  final http.Client httpClient = http.Client();
  SharedLibrary? sharedLibrary;

  Uri baseUri = Uri.http("localhost:8080");
  Map<String, String> defaultHeaders = {};
  List<RequestInterceptor> requestInterceptor = [];

  Future<T?> send<T>(String verb, String path,
      {required Object? body,
      required Encoding? encoding,
      required bool hasBody,
      required bool hasTypedResponse,
      required TypeTree reqBodyIdentifier,
      required TypeTree resBodyIdentifier,
      required Map<String, String> queryParameters,
      required Map<String, String> headerParameters}) async {
    var uri = baseUri.resolve(path).replace(queryParameters: queryParameters);

    var reqBodySerializer = sharedLibrary!
        .resolveBodySerializer(reqBodyIdentifier as QualifiedTypeTree)!;
    var reqBodyEncoding = reqBodySerializer.descriptor.encoding;

    var resBodySerializer = sharedLibrary!
        .resolveBodySerializer(resBodyIdentifier as QualifiedTypeTree)!;

    var request = http.Request(verb, uri);
    request.headers.addAll(defaultHeaders);
    request.headers.addAll(headerParameters);
    if (hasBody) {
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

    var streamedResponse = await httpClient.send(request);

    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      throw HttpClientException(streamedResponse.statusCode,
          "Request failed with status code ${streamedResponse.reasonPhrase}");
    }

    if (hasTypedResponse) {
      if (streamedResponse.statusCode == 204) {
        return null;
      }
      return await resBodySerializer.deserialize(streamedResponse.stream);
    } else {
      return await http.Response.fromStream(streamedResponse) as T;
    }
  }
}

class HttpClientException implements Exception {
  final int statusCode;
  final String message;

  HttpClientException(this.statusCode, this.message);
}
