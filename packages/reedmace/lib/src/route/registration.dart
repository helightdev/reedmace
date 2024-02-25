import 'dart:async';

import 'package:collection/collection.dart';
import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf.dart';

class InvocationAssembler {
  late List<ArgumentFactory> factories;

  InvocationAssembler(this.factories);

  Future<List<dynamic>> assembleArguments(RequestContext context) =>
      Future.wait(factories.map((factory) async => await factory(context)));
}

class RouteRegistration {
  final List<Interceptor> beforeInterceptors;
  final List<Interceptor> afterInterceptors;
  final RouteDefinition definition;
  final InvocationAssembler assembler;
  final ReedmaceBodySerializer responseBodySerializer;
  final List<ArgumentSupplier> assemblerSuppliers;

  RouteRegistration(
      this.beforeInterceptors,
      this.afterInterceptors,
      this.definition,
      this.assembler,
      this.assemblerSuppliers,
      this.responseBodySerializer);

  Object encodeResponseBody(dynamic value) {
    return responseBodySerializer.serialize(value);
  }

  Future<Response> run(RequestContext context) async {
    Response? response;
    // Early interceptor breakout
    for (var interceptor in beforeInterceptors) {
      var intercepted = interceptor.intercept(context, response);
      response = (intercepted is Response?) ? (intercepted ?? response) : (await intercepted ?? response);
    }
    if (response != null) return response;

    // Default method invocation
    try {
      var args = await assembler.assembleArguments(context);
      FutureOr<dynamic> resultFuture = definition.proxy(args);
      if (resultFuture is Res) {
        response = resultFuture.build(context);
      } else {
        var result = await resultFuture;
        if (result is! Res) {
          throw Exception(
              "Result of route ${definition.routeAnnotation.path} is not a Res");
        }
        response = result.build(context);
      }
    } on Res catch (e) {
      response = e.build(context);
    } catch (e, st) {
      response = Response.internalServerError();
      print("$e:\n$st");
    }

    // Late interceptor breakout
    for (var interceptor in afterInterceptors) {
      var intercepted = interceptor.intercept(context, response);
      response = (intercepted is Response?) ? (intercepted ?? response) : (await intercepted ?? response);
    }
    return response!;
  }

  void sortInterceptors() {
    beforeInterceptors.sortBy<num>((element) => element.sortIndex);
    afterInterceptors.sortBy<num>((element) => element.sortIndex);
  }

  @override
  String toString() {
    return "RouteRegistration{${definition.routeAnnotation.verb} ${definition.routeAnnotation.path}}";
  }
}
