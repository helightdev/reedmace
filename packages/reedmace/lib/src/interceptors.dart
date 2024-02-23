import 'dart:async';

import 'package:glob/glob.dart';
import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf.dart';

export 'interceptors/head.dart';
export 'interceptors/cors.dart';
export 'features/auth.dart';

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
