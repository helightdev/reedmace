import 'dart:async';

import 'package:conduit_open_api/v3.dart';
import 'package:lyell/lyell.dart';
import 'package:recase/recase.dart';
import 'package:reedmace/reedmace.dart';
import 'package:reedmace/src/base.dart';
import 'package:reedmace/src/route/definition.dart';
import 'package:reedmace/src/response.dart';
import 'package:routingkit/routingkit.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/src/body.dart';
import 'package:collection/collection.dart';

class RequestContext {
  final RouteRegistration routeRegistration;
  final Request request;
  final Params pathParams;
  final Map<String, String> queryParameters;
  final Reedmace reedmace;

  final Map<Object, Object?> _contextData = {};
  Map<String, Object> defaultResponseHeaders = {};

  RequestContext(this.reedmace, this.pathParams, this.queryParameters,
      this.request, this.routeRegistration);

  //region Context Data
  operator []=(Object key, Object? value) => _contextData[key] = value;

  Object? operator [](Object key) => _contextData[key];

  T get<T>({Object? key, T Function()? orElse}) {
    key ??= T;
    var data = _contextData[key] as T;
    if (data == null) {
      if (orElse != null) return orElse();
      throw Exception("No data for key $key");
    }
    return data;
  }

  T? getOrNull<T>([Object? key]) {
    key ??= T;
    return _contextData[key] as T?;
  }

  void set<T>(T value, {Object? key}) => _contextData[key ?? T] = value;

  //endregion

  static RequestContext fromRequest(Reedmace reedmace, Request request,
      RouteRegistration registration, Params params) {
    return RequestContext(
        reedmace, params, request.url.queryParameters, request, registration);
  }
}