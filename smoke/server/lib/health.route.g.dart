// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unused_field, unused_import, public_member_api_docs, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

import 'dart:core';
import 'dart:async';
import 'package:lyell/lyell.dart' as gen;
import 'package:reedmace/reedmace.dart' as gen;
import 'package:reedmace/src/request.dart' as gen0;
import 'package:reedmace/src/annotations.dart' as gen1;
import 'package:reedmace/src/response.dart' as gen2;
import 'dart:core' as gen3;
import 'package:smoke/health.dart' as gen4;
import 'package:reedmace/src/interceptors/sse.dart' as gen5;
import 'package:smoke/health.dart';

const health_descriptor = gen.RouteDefinition(
    'health',
    gen1.Route('/health', verb: 'GET'),
    [gen1.Route('/health', verb: 'GET')],
    gen.QualifiedTypeTreeN<gen2.Res<gen3.String>, gen2.Res<dynamic>>([gen.QualifiedTerminal<gen3.String>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<dynamic>, gen0.Req<dynamic>>([gen.QualifiedTerminal<dynamic>()]), false, 'req', [])
    ],
    _$health);
FutureOr<gen2.Res<gen3.String>> _$health(List<dynamic> args) => gen4.health(args[0]);
const healthStream_descriptor = gen.RouteDefinition(
    'healthStream',
    gen1.GET('/health-stream'),
    [gen1.GET('/health-stream'), gen5.sse],
    gen.QualifiedTypeTreeN<gen2.Res<dynamic>, gen2.Res<dynamic>>([gen.QualifiedTerminal<dynamic>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<dynamic>, gen0.Req<dynamic>>([gen.QualifiedTerminal<dynamic>()]), false, 'req', [])
    ],
    _$healthStream);
FutureOr<gen2.Res<dynamic>> _$healthStream(List<dynamic> args) => gen4.healthStream(args[0]);
