import 'dart:async';

import 'package:conduit_open_api/v3.dart';
import 'package:lyell/lyell.dart';
import 'package:reedmace/reedmace.dart';

export 'suppliers/request.dart';
export 'suppliers/request_variable.dart';

typedef ArgumentFactory = FutureOr<dynamic> Function(RequestContext context);

abstract class ArgumentSupplier extends RetainedAnnotation {
  final int sortIndex;

  const ArgumentSupplier([this.sortIndex = 100]);

  bool check(MethodArgument argument, Reedmace reedmace,
      RouteDefinition definition) =>
      supply(argument, reedmace, definition) != null;

  ArgumentFactory? supply(
      MethodArgument argument, Reedmace reedmace, RouteDefinition definition) {
    return null;
  }

  void modifyApiOperation(APIOperation operation, MethodArgument argument,
      Reedmace reedmace, RouteDefinition definition) {}
}