import 'dart:async';

import 'package:conduit_open_api/v3.dart';
import 'package:glob/glob.dart';
import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf.dart';

export 'interceptors/head.dart';
export 'interceptors/cors.dart';
export 'features/auth.dart';
export 'interceptors/sse.dart';

enum InterceptorType {
  before,
  after,
  around,
}

abstract class Interceptor {
  final InterceptorType type;
  final int sortIndex;

  const Interceptor({this.type = InterceptorType.around, this.sortIndex = 0});

  FutureOr<Response?> intercept(RequestContext context, Response? response);
}

abstract class RegistrationInterceptor {
  final int sortIndex;

  const RegistrationInterceptor({this.sortIndex = 0});

  void postRegistration(Reedmace reedmace, RouteRegistration registration,
      RouterTerminalNode node);

  RegistrationInterceptor restrictedTo(String pathGlob) {
    return RestrictedInterceptor(this, Glob(pathGlob));
  }

  void modifyApiOperation(Reedmace reedmace, RouteDefinition definition, APIOperation operation) {}

  void modifyDefaultResponse(Reedmace reedmace, RouteDefinition definition, APIResponse response) {}

}

class RestrictedInterceptor extends RegistrationInterceptor {
  final RegistrationInterceptor delegate;
  final Glob pathGlob;

  RestrictedInterceptor(this.delegate, this.pathGlob)
      : super(sortIndex: delegate.sortIndex);

  @override
  void postRegistration(Reedmace reedmace, RouteRegistration registration,
      RouterTerminalNode node) {
    if (pathGlob.matches(registration.definition.routeAnnotation.openApiPath)) {
      delegate.postRegistration(reedmace, registration, node);
    }
  }
}
