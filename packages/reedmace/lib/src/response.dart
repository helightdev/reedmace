import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:conduit_open_api/v3.dart';
import 'package:lyell/lyell.dart';
import 'package:reedmace/reedmace.dart';
import 'package:reedmace/src/context.dart';
import 'package:shelf/shelf.dart';

sealed class Res<T> with TypeCaptureMixin<T> {
  const Res._();

  Response build(RequestContext context);

  factory Res.response(Response response, {bool addDefaultHeaders = true}) =>
      RawRes<T>(response, addDefaultHeaders);

  factory Res(T? content, {int? statusCode, Map<String, String>? headers}) =>
      ContentRes<T>(content, statusCode, headers);

  factory Res.content(T? content,
          {int? statusCode, Map<String, String>? headers}) =>
      ContentRes<T>(content, statusCode, headers);

  // Short hand methods for successful responses
  factory Res.ok([T? content]) => ContentRes<T>(content, 200, {});

  factory Res.created([T? content]) => ContentRes<T>(content, 201, {});

  factory Res.noContent() => ContentRes<T>(null, 204, {});

  factory Res.error(int statusCode, String message,
          {Map<String, String>? headers}) =>
      ErrorRes<T>(message, statusCode, headers);

  factory Res.sse({
    required Stream<T> Function()? create,
  }) =>
      SseRes<T>(create!());

  static QualifiedTypeTree tree<T>() =>
      QualifiedTypeTree.arg1<Res<T>, Res, T>();
}

class HttpExceptions {
  HttpExceptions._();

  static Res<T> notFound<T>([String message = ""]) {
    return Res.error(404, message);
  }

  static Res<T> badRequest<T>([String message = ""]) {
    return Res.error(400, message);
  }

  static Res<T> unauthorized<T>([String message = ""]) {
    return Res.error(401, message);
  }

  static Res<T> forbidden<T>([String message = ""]) {
    return Res.error(403, message);
  }

  static Res<T> internalServerError<T>([String message = ""]) {
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
    var headers = <String, Object>{
      ...context.defaultResponseHeaders,
      ...?this.headers
    };

    var successStatus = content == null ? 204 : 200;

    Object? body;
    if (content != null && T != dynamic) {
      body = context.routeRegistration.encodeResponseBody(content);
    }

    return Response(statusCode ?? successStatus, headers: headers, body: body);
  }
}

class ErrorRes<T> extends Res<T> {
  final String message;
  final int statusCode;
  final Map<String, Object>? headers;

  const ErrorRes(this.message, this.statusCode, this.headers) : super._();

  @override
  Response build(RequestContext context) {
    var headers = <String, Object>{
      ...context.defaultResponseHeaders,
      ...?this.headers,
      "content-type": "application/problem+json"
    };

    Map<String, dynamic> errorBody = {
      "status": statusCode,
      "error": message,
    };
    return Response(statusCode,
        body: jsonEncode(errorBody), headers: headers, encoding: utf8);
  }
}

class RawRes<T> extends Res<T> {
  final Response response;
  final bool addDefaultHeaders;

  const RawRes(this.response, this.addDefaultHeaders) : super._();

  @override
  Response build(RequestContext context) {
    if (addDefaultHeaders) {
      return response.change(
          headers: {...context.defaultResponseHeaders, ...response.headers});
    } else {
      return response;
    }
  }
}

class SseRes<T> extends Res<T> {
  Stream<T>? innerStream;

  SseRes([this.innerStream]) : super._();

  final StreamController<List<int>> _controller = StreamController<List<int>>();

  void send(SseChunk chunk) {
    _controller.add(chunk.toBytes());
  }

  void close() {
    _controller.close();
  }

  void _pipeStreamIfAvailable(RequestContext context) {
    if (innerStream == null) return;
    if (T == SseChunk || T == dynamic) {
      innerStream!.listen((event) {
        if (event is SseChunk) {
          send(event);
        }
      }, onDone: close);
    } else {
      innerStream!.listen((event) {
        var encoded = context.routeRegistration.encodeResponseBody(event);
        switch (encoded) {
          case String():
            send(SseChunk(encoded));
            break;
          case List<int>():
            send(SseChunk(base64Encode(encoded)));
            break;
          case SseChunk():
            send(encoded);
            break;
          default:
            throw Exception("Invalid type for SSE stream");
        }
      }, onDone: close);
    }
    innerStream = null;
  }

  @override
  Response build(RequestContext context) {
    _pipeStreamIfAvailable(context);
    return Response.ok(_controller.stream,
        headers: {"Content-Type": "text/event-stream"},
        context: {"shelf.io.buffer_output": false});
  }
}
