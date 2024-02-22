import 'dart:async';

import 'package:reedmace/reedmace.dart';
import 'package:shelf/src/response.dart';

const ACCESS_CONTROL_ALLOW_ORIGIN = 'Access-Control-Allow-Origin';
const ACCESS_CONTROL_EXPOSE_HEADERS = 'Access-Control-Expose-Headers';
const ACCESS_CONTROL_ALLOW_CREDENTIALS = 'Access-Control-Allow-Credentials';
const ACCESS_CONTROL_ALLOW_HEADERS = 'Access-Control-Allow-Headers';
const ACCESS_CONTROL_ALLOW_METHODS = 'Access-Control-Allow-Methods';
const ACCESS_CONTROL_MAX_AGE = 'Access-Control-Max-Age';
const VARY = 'Vary';

const ORIGIN = 'origin';

const _defaultHeadersList = [
  'accept',
  'accept-encoding',
  'authorization',
  'content-type',
  'dnt',
  'origin',
  'user-agent',
];

const _defaultMethodsList = [
  'DELETE',
  'GET',
  'OPTIONS',
  'PATCH',
  'POST',
  'PUT'
];

Map<String, String> _defaultHeaders = {
  ACCESS_CONTROL_EXPOSE_HEADERS: '',
  ACCESS_CONTROL_ALLOW_CREDENTIALS: 'true',
  ACCESS_CONTROL_ALLOW_HEADERS: _defaultHeadersList.join(','),
  ACCESS_CONTROL_ALLOW_METHODS: _defaultMethodsList.join(','),
  ACCESS_CONTROL_MAX_AGE: '86400',
};

final _defaultHeadersAll =
_defaultHeaders.map((key, value) => MapEntry(key, [value]));

typedef OriginChecker = bool Function(String origin);

bool originAllowAll(String origin) => true;

OriginChecker originOneOf(List<String> origins) =>
        (origin) => origins.contains(origin);


class CorsRegistrationInterceptor extends RegistrationInterceptor {

  final OriginChecker originChecker;
  CorsRegistrationInterceptor([this.originChecker = originAllowAll]);

  late final CorsRequestInterceptor corsRequestInterceptor = CorsRequestInterceptor(originChecker);

  @override
  void postRegistration(Reedmace reedmace, RouteRegistration registration, RouterTerminalNode node) {
    registration.beforeInterceptors.add(corsRequestInterceptor);
    if (node.verbs[HttpVerb.options] == null) {
      reedmace.registerRoute(RouteDefinition.fromFunction<dynamic,dynamic>((request) async {
        return Res(null, statusCode: 200);
      }, registration.definition.routeAnnotation.copyWith(verb: HttpVerb.options)));
    }
  }
}

class CorsRequestInterceptor extends Interceptor {

  final OriginChecker originsChecker;

  CorsRequestInterceptor(this.originsChecker) : super(type: InterceptorType.before, sortIndex: -25);

  @override
  FutureOr<Response?> intercept(RequestContext context, Response? response) {
    var origin = context.request.headers[ORIGIN];
    if (origin == null) {
      return null;
    }
    if (!originsChecker(origin)) {
      return Response.forbidden("Origin not allowed");
    }

    context.defaultResponseHeaders.addAll({
      ..._defaultHeaders,
      ACCESS_CONTROL_ALLOW_ORIGIN: origin,
    });
    return null;
  }

}