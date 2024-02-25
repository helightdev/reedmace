import 'dart:async';

import 'package:conduit_open_api/v3.dart';
import 'package:reedmace/reedmace.dart';
import 'package:reedmace/src/suppliers/header_params.dart';
import 'package:reedmace/src/suppliers/query_params.dart';
import 'package:shelf/shelf.dart';
import 'package:collection/collection.dart';

part 'base_apidocs.dart';
part 'base_requests.dart';

typedef StartupHookFunction = FutureOr<void> Function(Reedmace reedmace);

class Reedmace {
  final ReedmaceRouter router = ReedmaceRouter();
  final List<ArgumentSupplier> argumentSuppliers = [
    ReqArgumentSupplier(),
    ValueReqArgumentSupplier(),
    RequestVariableArgumentSupplier(),
    QueryParamArgumentSupplier(),
    HeaderParamArgumentSupplier(),
    PrincipalSupplier()
  ];
  final List<RegistrationInterceptor> registrationInterceptors = [
    AutomaticHeadInterceptor(),
    CorsRegistrationInterceptor()
  ];
  final List<StartupHookFunction> startupFunctions = [];
  SharedLibrary? _sharedLibrary;

  set sharedLibrary(SharedLibrary library) {
    _sharedLibrary = library;
  }

  SharedLibrary get sharedLibrary {
    if (_sharedLibrary == null) {
      throw StateError(
        "Shared library not set, please initialize the Reedmace instance "
            "with a shared library in your configure function. "
            "The shared library should be the first thing you initialize.");
    }
    return _sharedLibrary!;
  }

  HttpServerConfiguration serverConfiguration = HttpServerConfiguration();
  Pipeline pipeline = Pipeline();

  Handler get handler => pipeline.addHandler(handle);

  Future configure(dynamic Function(Reedmace reedmace) function) async {
    await (function(this) as FutureOr<dynamic>);
    await sharedLibrary.configure();
  }

  void addMiddleware(Middleware middleware) {
    pipeline = pipeline.addMiddleware(middleware);
  }

  void addInterceptor(RegistrationInterceptor interceptor) {
    registrationInterceptors.add(interceptor);
  }

  void onStartup(StartupHookFunction function) {
    startupFunctions.add(function);
  }

  Future<void> runStartupHooks() async {
    for (var function in startupFunctions) {
      await function(this);
    }
  }
}
