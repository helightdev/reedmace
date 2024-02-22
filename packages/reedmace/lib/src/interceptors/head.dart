import 'dart:async';

import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf.dart';

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

class AutomaticHeadInterceptor extends RegistrationInterceptor {
  const AutomaticHeadInterceptor();

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