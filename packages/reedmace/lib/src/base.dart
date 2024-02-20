import 'dart:async';
import 'dart:convert';

import 'package:conduit_open_api/v3.dart';
import 'package:lyell/lyell.dart';
import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf.dart';
import 'package:collection/collection.dart';

class Reedmace {
  final ReedmaceRouter router = ReedmaceRouter();
  final List<ArgumentSupplier> argumentSuppliers = [
    ReqArgumentSupplier(),
    PathVariableArgumentSupplier()
  ];
  final List<RegistrationInterceptor> registrationInterceptors = [
    BodyHeadHandlerInterceptor()
  ];
  SharedLibrary? sharedLibrary;

  List<ReedmaceSerializerModule> get modules =>
      sharedLibrary!.serializerModules;

  Future configure(dynamic Function(Reedmace reedmace) function) async {
    await (function(this) as FutureOr<dynamic>);
    await sharedLibrary!.configure();
  }

  Future<Response> handle(Request request) async {
    var watch = Stopwatch()..start();
    var routerResult = router.handle(request);
    if (routerResult == null) {
      return Response.notFound("Not found");
    }
    var (registration, params) = routerResult;
    var context = RequestContext.fromRequest(this, request, registration, params);
    var result = await registration.run(context);
    watch.stop();
    print("Request took ${watch.elapsedMicroseconds}μs");
    return result;
  }

  void registerRoute(RouteDefinition definition) {
    print("Registering with auto route id: ${definition.routeAnnotation.toString()}");
    var registration = buildRegistration(definition);
    var entry = router.register(registration);
    for (var interceptor
        in definition.annotations.whereType<RegistrationInterceptor>()) {
      interceptor.postRegistration(this, registration, entry);
    }
    for (var interceptor in registrationInterceptors
        .sortedBy<num>((element) => element.sortIndex)) {
      interceptor.postRegistration(this, registration, entry);
    }
  }

  ArgumentSupplier getFactory(
      RouteDefinition definition, MethodArgument argument) {
    var manualArgumentSupplier =
        argument.annotations.whereType<ArgumentSupplier>().firstOrNull;
    if (manualArgumentSupplier != null) {
      return manualArgumentSupplier;
    }

    for (var element
        in argumentSuppliers.sortedBy<num>((element) => element.sortIndex)) {
      if (element.check(argument, this, definition)) return element;
    }
    throw ArgumentError("No factory found for $argument");
  }

  APIDocument buildDocument() {
    var document = APIDocument();
    document.version = "3.0.0";
    document.info = APIInfo("Reedmace API", "0.0.1");
    document.paths = Map.of(router.apiRoutes).map((key, value) {
      var copiedMap = Map.of(value.verbs);
      copiedMap.remove("OPTIONS");
      copiedMap.remove("HEAD");

      var operationsMap = copiedMap.map((key, value) {
        return MapEntry(key, getOperation(value));
      });

      if (value.catchAll != null) {
        var freeVerbs = HttpVerb.getFreeVerbs(copiedMap);
        if (freeVerbs.isNotEmpty) {
          operationsMap[freeVerbs.first] = getOperation(value.catchAll!)
            ..extensions["x-verbs"] = freeVerbs;
        }
      }

      return MapEntry(key, APIPath(operations: operationsMap));
    })
      ..removeWhere((key, value) => value!.operations.isEmpty);
    document.components = APIComponents();
    for (var element in modules) {
      element.contribute(document);
    }

    //print(jsonEncode(document.asMap()));

    /*
    for (var route in router.) {
      var operation = getOperation(route.definition);
      document.addOperation(route.definition.routeAnnotation.path, route.definition.routeAnnotation.verb, operation);
    }
     */
    return document;
  }

  APIOperation getOperation(RouteRegistration registration) {
    var definition = registration.definition;
    var bodySerializer =
        sharedLibrary!.resolveBodySerializer(definition.innerResponse)!;
    var response = switch (bodySerializer.identifier) {
      "none" => APIResponse.schema("success", APISchemaObject.freeForm()),
      _ => APIResponse.schema(
          "success",
          contentTypes: [bodySerializer.descriptor.contentType],
          bodySerializer.getSchema() ?? APISchemaObject.freeForm()),
    };

    var operation = APIOperation(definition.functionName, {
      "200": response,
    });

    operation.extensions["x-response-identifier"] = bodySerializer.identifier;

    for (var (i, supplier) in registration.assemblerSuppliers.indexed) {
      var argument = registration.definition.arguments[i];
      supplier.modifyApiOperation(operation, argument, this, definition);
    }
    return operation;
  }

  RouteRegistration buildRegistration(RouteDefinition definition) {
    var interceptors = definition.annotations.whereType<Interceptor>().toList();

    var assemblerArguments = definition.arguments
        .map((e) => (e, getFactory(definition, e)))
        .toList();

    var assembler = InvocationAssembler(assemblerArguments
        .map((e) => e.$2.supply(e.$1, this, definition)!)
        .toList());

    var registration = RouteRegistration(
        interceptors
            .where((element) =>
                element.type == InterceptorType.before ||
                element.type == InterceptorType.around)
            .toList(),
        interceptors
            .where((element) =>
                element.type == InterceptorType.after ||
                element.type == InterceptorType.around)
            .toList(),
        definition,
        assembler,
        assemblerArguments.map((e) => e.$2).toList(),
        sharedLibrary!.resolveBodySerializer(definition.innerResponse)!);
    return registration;
  }
}
