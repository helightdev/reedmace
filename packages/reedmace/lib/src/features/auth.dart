import 'dart:async';

import 'package:lyell/lyell.dart';
import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf.dart';

class AuthSchemeInterceptor extends RegistrationInterceptor
    implements Interceptor {
  final String authType;
  final FutureOr<Principal?> Function(String? token) authenticator;

  const AuthSchemeInterceptor(this.authType, this.authenticator);

  @override
  Future<Response?> intercept(
      RequestContext context, Response? response) async {
    // If principal is already set, do nothing
    if (context.getOrNull<Principal>() != null) return null;

    // If no authorization header is present, do nothing
    if (context.request.headers['authorization'] == null) {
      return null;
    }

    var auth = context.request.headers['authorization']!;
    if (auth.startsWith(authType)) {
      try {
        var token = auth.substring(authType.length).trim();
        var principal = await authenticator(token);
        if (principal != null) {
          context.set<Principal>(principal);
        }
      } on Res catch (e) {
        return e.build(context);
      } catch (e) {
        return Response.forbidden("Invalid authentication");
      }
    }
    return null;
  }

  @override
  void postRegistration(Reedmace reedmace, RouteRegistration registration,
      RouterTerminalNode node) {
    registration.beforeInterceptors.add(this);
  }

  @override
  int get sortIndex => -10;

  @override
  InterceptorType get type => InterceptorType.before;
}

const RequiresAuthentication authenticated = RequiresAuthentication();

class RequiresAuthentication extends Interceptor implements RetainedAnnotation {
  const RequiresAuthentication()
      : super(type: InterceptorType.before, sortIndex: -5);

  @override
  FutureOr<Response?> intercept(RequestContext context, Response? response) {
    if (context.getOrNull<Principal>() == null) {
      return Response.unauthorized("Authentication required");
    }
    return null;
  }
}

class RequiresRole extends Interceptor implements RetainedAnnotation {
  final String role;

  const RequiresRole(this.role)
      : super(type: InterceptorType.before, sortIndex: -5);

  @override
  FutureOr<Response?> intercept(RequestContext context, Response? response) {
    var principal = context.getOrNull<Principal>();
    if (principal == null) {
      return Response.unauthorized("Authentication required");
    }
    if (!principal.roles.contains(role)) {
      return Response.forbidden("Insufficient permissions");
    }
    return null;
  }
}

class PrincipalSupplier extends ArgumentSupplier {

  PrincipalSupplier() : super();

  @override
  ArgumentFactory? supply(
      MethodArgument argument, Reedmace reedmace, RouteDefinition definition) {
    if (argument.type.typeArgument == Principal) {
      return switch(argument.nullable) {
        true => (context) => context.getOrNull<Principal>(),
        false => (context) => context.get<Principal>()
      };
    }
    return null;
  }
}

abstract class Principal {
  String get id;
  String get name;
  Set<String> get roles;

  factory Principal.simple(String id, String name, Set<String> roles) {
    return SimplePrincipal(id, name, roles);
  }
}

class SimplePrincipal implements Principal {
  @override
  final String id;
  @override
  final String name;
  @override
  final Set<String> roles;

  SimplePrincipal(this.id, this.name, this.roles);
}
