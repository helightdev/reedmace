import 'dart:async';

import 'package:conduit_open_api/v3.dart';
import 'package:lyell/lyell.dart';
import 'package:recase/recase.dart';
import 'package:reedmace/reedmace.dart';
import 'package:reedmace/src/base.dart';
import 'package:reedmace/src/definition.dart';
import 'package:reedmace/src/response.dart';
import 'package:routingkit/routingkit.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/src/body.dart';
import 'package:collection/collection.dart';

typedef ArgumentFactory = FutureOr<dynamic> Function(RequestContext context);

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

abstract class ArgumentSupplier extends RetainedAnnotation {
  final int sortIndex;

  const ArgumentSupplier([this.sortIndex = 100]);

  bool check(MethodArgument argument, Reedmace reedmace,
          RouteDefinition definition) =>
      supply(argument, reedmace, definition) != null;

  ArgumentFactory? supply(
      MethodArgument argument, Reedmace reedmace, RouteDefinition definition) {
    return null;
  }

  void modifyApiOperation(APIOperation operation, MethodArgument argument,
      Reedmace reedmace, RouteDefinition definition) {}
}

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
          reedmace.sharedLibrary!.resolveBodySerializer(argumentTree)!;
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

class PathVariableArgumentSupplier extends ArgumentSupplier {
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
    if (argument.name.startsWith(r"$$")) {
      var name = argument.name.substring(2).headerCase;
      return switch (argument.nullable) {
        true => (context) => context.request.headers[name],
        false => (context) {
            var header = context.request.headers[name];
            if (header == null)
              throw HttpExceptions.badRequest("Missing required header $name");
            return header;
          }
      };
    } else if (argument.name.startsWith(r"$")) {
      var name = argument.name.substring(1).snakeCase;
      return switch (argument.nullable) {
        true => (context) => context.queryParameters[name],
        false => (context) {
            var parameter = context.queryParameters[name];
            if (parameter == null)
              throw HttpExceptions.badRequest(
                  "Missing required query parameter $name");
            return parameter;
          }
      };
    }
    return null;
  }

  @override
  void modifyApiOperation(APIOperation operation, MethodArgument argument,
      Reedmace reedmace, RouteDefinition definition) {
    var pathVariables = definition.routeAnnotation.pathVariables;
    if (pathVariables.contains(argument.name)) {
      operation.addParameter(APIParameter.path(argument.name));
    } else if (argument.name.startsWith(r"$$")) {
      var name = argument.name.substring(2).headerCase;
      operation.addParameter(APIParameter.header(name,
          isRequired: !argument.nullable, schema: APISchemaObject.string()));
    } else if (argument.name.startsWith(r"$")) {
      var name = argument.name.substring(1).snakeCase;
      operation.addParameter(APIParameter.query(name,
          isRequired: !argument.nullable, schema: APISchemaObject.string()));
    }
  }
}

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
      var intercepted = await interceptor.intercept(context, null);
      response = intercepted ?? response;
    }
    if (response != null) return response;

    // Default method invocation
    try {
      var invoke = await assembler.assembleArguments(context);
      FutureOr<dynamic> resultFuture = definition.proxy(invoke);
      var result = await resultFuture;
      if (result is! Res)
        throw Exception(
            "Result of route ${definition.routeAnnotation.path} is not a Res");
      response = result.build(context);
    } on Res catch (e) {
      response = e.build(context);
    } catch (e, st) {
      response = Response.internalServerError();
      print("$e:\n$st");
    }

    // Late interceptor breakout
    for (var interceptor in afterInterceptors) {
      var intercepted = await interceptor.intercept(context, null);
      response = intercepted ?? response;
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
