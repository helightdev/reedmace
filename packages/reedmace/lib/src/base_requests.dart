part of 'base.dart';

extension BaseRequestsExtension on Reedmace {

  Future<Response> handle(Request request) async {
    var watch = Stopwatch()..start();
    var routerResult = router.handle(request);
    if (routerResult == null) {
      return Response.notFound("Not found");
    }
    var (registration, params) = routerResult;
    var context = RequestContext(
        this, params, request.url.queryParameters, request, registration);
    var result = await registration.run(context);
    watch.stop();
    print("Request took ${watch.elapsedMicroseconds}μs");
    return result;
  }

  void registerRoute(RouteDefinition definition) {
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

    registration.sortInterceptors();
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

  RouteRegistration buildRegistration(RouteDefinition definition) {
    var interceptors = definition.annotations.whereType<Interceptor>().toList();

    var assemblerArguments = definition.arguments
        .map((e) => (e, getFactory(definition, e)))
        .toList();

    var assembler = InvocationAssembler(assemblerArguments
        .map((e) => e.$2.supply(e.$1, this, definition)!)
        .toList());

    var resolvedBodySerializer =
        sharedLibrary.resolveBodySerializer(definition.innerResponse);
    if (resolvedBodySerializer == null) {
      throw ArgumentError(
          "No body serializer found for ${definition.innerResponse}");
    }

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
        resolvedBodySerializer);
    return registration;
  }
}
