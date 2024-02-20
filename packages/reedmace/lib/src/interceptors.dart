
import 'dart:async';

import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf.dart';

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

abstract class RegistrationInterceptor{

  final int sortIndex;

  const RegistrationInterceptor({this.sortIndex = 0});

  void postRegistration(Reedmace reedmace, RouteRegistration registration, RouterTerminalNode node);
}

class RemoveBodyInterceptor extends Interceptor {
  const RemoveBodyInterceptor() : super(type: InterceptorType.after);

  @override
  FutureOr<Response?> intercept(RequestContext context, Response? response) {
    if (response != null) {
      return response.change(body: null);
    }
    return null;
  }
}

class BodyHeadHandlerInterceptor extends RegistrationInterceptor {
  const BodyHeadHandlerInterceptor();

  @override
  void postRegistration(Reedmace reedmace, RouteRegistration registration, RouterTerminalNode node) {
    if (registration.definition.routeAnnotation.verb == "GET") {
      if (node.verbs["HEAD"] == null) {
        var headRegistration = reedmace.buildRegistration(registration.definition);
        headRegistration.afterInterceptors.insert(0, RemoveBodyInterceptor());
        node.verbs["HEAD"] = headRegistration;
      }
    }
  }
}