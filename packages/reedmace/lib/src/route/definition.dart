import 'dart:async';

import 'package:lyell/lyell.dart';
import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

class RouteDefinition {
  final String functionName;
  final Route routeAnnotation;
  final List<RetainedAnnotation> annotations;
  final QualifiedTypeTree response;
  final List<MethodArgument> arguments;
  final MethodProxy proxy;

  const RouteDefinition(this.functionName, this.routeAnnotation,
      this.annotations, this.response, this.arguments, this.proxy);

  static RouteDefinition dynamicMock(String path, String verb) =>
      RouteDefinition(
          "$verb$path",
          Route(path, verb: verb),
          [],
          QualifiedTypeTree.arg1<Res<dynamic>, Res, dynamic>(),
          [
            MethodArgument(QualifiedTypeTree.arg1<Req<dynamic>, Req, dynamic>(),
                false, "request", [])
          ],
          (args) => Res.error(200, "success"));

  RouteRegistration emptyRegistration() => RouteRegistration(
      [], [], this, InvocationAssembler([]), [], StringSerializer());

  QualifiedTypeTree get innerResponse => switch (response.arguments.isEmpty) {
        true => QualifiedTypeTree.terminal<dynamic>(),
        false => response.arguments[0] as QualifiedTypeTree
      };

  static RouteDefinition fromShelf(Handler handler, Route route) =>
      fromFunction<dynamic, dynamic>((request) async {
        var response = await handler(request.context.request);
        return Res.response(response);
      }, route);

  static RouteDefinition fromFunction<FROM, TO>(
    FutureOr<Res<TO>> Function(Req<FROM> request) function,
    Route route, {
    QualifiedTypeTree? responseTree,
    QualifiedTypeTree? requestTree,
    List<RetainedAnnotation>? annotations,
  }) {
    var arguments = [
      MethodArgument(requestTree ?? Req.tree<FROM>(), false, "request", [])
    ];
    return RouteDefinition(
        function.toString(),
        route,
        [route, ...?annotations],
        responseTree ?? Res.tree<TO>(),
        arguments,
        (args) => function(args[0] as Req<FROM>));
  }

  static RouteDefinition create<REQ, RES>(
    FutureOr<RES> Function(REQ request, Map<String, dynamic> args) function,
    Route route, {
    required QualifiedTypeTree request,
    required QualifiedTypeTree response,
    required List<MethodArgument> args,
    List<RetainedAnnotation> annotations = const [],
  }) {
    return RouteDefinition(
        route.toString(),
        route,
        [route, ...annotations],
        response,
        [MethodArgument(request, false, "request", []), ...args], (argList) {
      var req = argList[0] as REQ;
      var argsMap = <String, dynamic>{};
      for (var i = 1; i < argList.length; i++) {
        argsMap[args[i-1].name] = argList[i];
      }

      return function(req, argsMap);
    });
  }

  MethodArgument? findArgument(String name) {
    for (var i = 0; i < arguments.length; i++) {
      if (arguments[i].name == name) {
        return arguments[i];
      }
    }
    return null;
  }
}

class MethodArgument {
  final QualifiedTypeTree type;
  final bool nullable;
  final String name;
  final List<RetainedAnnotation> annotations;

  const MethodArgument(this.type, this.nullable, this.name, this.annotations);
}

typedef MethodProxy = FutureOr<dynamic> Function(List<dynamic> args);
