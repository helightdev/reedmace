import 'dart:convert';

import 'package:lyell/lyell.dart';
import 'package:reedmace/src/context.dart';
import 'package:shelf/shelf.dart';

sealed class Res<T> with TypeCaptureMixin<T> {

  const Res._();

  Response build(RequestContext context);
  factory Res.response(Response response) => RawRes<T>(response);
  factory Res(T? content, {int? statusCode, Map<String, String>? headers}) =>
      ContentRes<T>(content, statusCode, headers);
  factory Res.content(T? content, {int? statusCode, Map<String, String>? headers}) =>
      ContentRes<T>(content, statusCode, headers);

  // Short hand methods for successful responses
  factory Res.ok([T? content]) =>
      ContentRes<T>(content, 200, {});
  factory Res.created([T? content]) =>
      ContentRes<T>(content, 201, {});
  factory Res.noContent() =>
      ContentRes<T>(null, 204, {});


  factory Res.error(int statusCode, String message, {Map<String, String>? headers}) =>
      ErrorRes<T>(message, statusCode, headers);

}

class HttpExceptions {
  static Object notFound([String message = ""]) {
    return Res.error(404, message);
  }

  static Object badRequest([String message = ""]) {
    return Res.error(400, message);
  }

  static Object unauthorized([String message = ""]) {
    return Res.error(401, message);
  }

  static Object forbidden([String message = ""]) {
    return Res.error(403, message);
  }

  static Object internalServerError([String message = ""]) {
    return Res.error(500, message);
  }
}

class ContentRes<T> extends Res<T> {
  final T? content;
  final int? statusCode;
  final Map<String, Object>? headers;

  const ContentRes(this.content, this.statusCode, this.headers) : super._();

  @override
  Response build(RequestContext context) {
    var headers = <String,Object>{
      ...context.defaultResponseHeaders,
      ...?this.headers
    };

    var successStatus = content == null ? 204 : 200;

    Object? body;
    if (content != null && T != dynamic) {
      body = context.routeRegistration.encodeResponseBody(content);
    }

    return Response(
      statusCode ?? successStatus,
      headers: headers,
      body: body
    );
  }
}

class ErrorRes<T> extends Res<T> {
  final String message;
  final int statusCode;
  final Map<String, Object>? headers;

  const ErrorRes(this.message, this.statusCode, this.headers) : super._();

  @override
  Response build(RequestContext context) {
    var headers = <String,Object>{
      ...context.defaultResponseHeaders,
      ...?this.headers
    };
    
    return Response(statusCode, body: message, headers: headers, encoding: utf8);
  }

}

class RawRes<T> extends Res<T> {

  final Response response;

  const RawRes(this.response) : super._();

  @override
  Response build(RequestContext context) {
    return response;
  }
}