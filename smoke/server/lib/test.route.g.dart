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
import 'package:smoke/test.dart' as gen4;
import 'package:shared/models.dart' as gen5;
import 'package:smoke/test.dart';

const sync_descriptor = gen.RouteDefinition(
    'sync',
    gen1.GET('/sync'),
    [gen1.GET('/sync')],
    gen.QualifiedTypeTreeN<gen2.Res<gen3.String>, gen2.Res<dynamic>>([gen.QualifiedTerminal<gen3.String>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<dynamic>, gen0.Req<dynamic>>([gen.QualifiedTerminal<dynamic>()]), false, 'req', [])
    ],
    _$sync);
FutureOr<gen2.Res<gen3.String>> _$sync(List<dynamic> args) => gen4.sync(args[0]);
const getTest_descriptor = gen.RouteDefinition(
    'getTest',
    gen1.GET('/test'),
    [gen1.GET('/test')],
    gen.QualifiedTypeTreeN<gen2.Res<gen3.String>, gen2.Res<dynamic>>([gen.QualifiedTerminal<gen3.String>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<dynamic>, gen0.Req<dynamic>>([gen.QualifiedTerminal<dynamic>()]), false, 'req', [])
    ],
    _$getTest);
FutureOr<gen2.Res<gen3.String>> _$getTest(List<dynamic> args) => gen4.getTest(args[0]);
const postTest_descriptor = gen.RouteDefinition(
    'postTest',
    gen1.POST('/test'),
    [gen1.POST('/test')],
    gen.QualifiedTypeTreeN<gen2.Res<gen3.String>, gen2.Res<dynamic>>([gen.QualifiedTerminal<gen3.String>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<gen3.String>, gen0.Req<dynamic>>([gen.QualifiedTerminal<gen3.String>()]), false, 'req', [])
    ],
    _$postTest);
FutureOr<gen2.Res<gen3.String>> _$postTest(List<dynamic> args) => gen4.postTest(args[0]);
const getUser_descriptor = gen.RouteDefinition(
    'getUser',
    gen1.GET('/user/:id'),
    [gen1.GET('/user/:id')],
    gen.QualifiedTypeTreeN<gen2.Res<gen3.String>, gen2.Res<dynamic>>([gen.QualifiedTerminal<gen3.String>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<dynamic>, gen0.Req<dynamic>>([gen.QualifiedTerminal<dynamic>()]), false, 'req', []),
      gen.MethodArgument(gen.QualifiedTerminal<gen3.String>(), false, 'id', [])
    ],
    _$getUser);
FutureOr<gen2.Res<gen3.String>> _$getUser(List<dynamic> args) => gen4.getUser(args[0], args[1]);
const getQuery_descriptor = gen.RouteDefinition(
    'getQuery',
    gen1.GET('/query'),
    [gen1.GET('/query')],
    gen.QualifiedTypeTreeN<gen2.Res<gen3.String>, gen2.Res<dynamic>>([gen.QualifiedTerminal<gen3.String>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<dynamic>, gen0.Req<dynamic>>([gen.QualifiedTerminal<dynamic>()]), false, 'req', []),
      gen.MethodArgument(gen.QualifiedTerminal<gen3.String>(), false, '\$skip', []),
      gen.MethodArgument(gen.QualifiedTerminal<gen3.String>(), true, '\$limit', [])
    ],
    _$getQuery);
FutureOr<gen2.Res<gen3.String>> _$getQuery(List<dynamic> args) => gen4.getQuery(args[0], args[1], args[2]);
const getHeaders_descriptor = gen.RouteDefinition(
    'getHeaders',
    gen1.GET('/headers'),
    [gen1.GET('/headers')],
    gen.QualifiedTypeTreeN<gen2.Res<gen3.String>, gen2.Res<dynamic>>([gen.QualifiedTerminal<gen3.String>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<dynamic>, gen0.Req<dynamic>>([gen.QualifiedTerminal<dynamic>()]), false, 'req', []),
      gen.MethodArgument(gen.QualifiedTerminal<gen3.String>(), false, '\$\$Authorization', []),
      gen.MethodArgument(gen.QualifiedTerminal<gen3.String>(), true, 'a', [gen1.HeaderParam('A')]),
      gen.MethodArgument(gen.QualifiedTerminal<gen3.String>(), true, 'b', [gen1.HeaderParam()])
    ],
    _$getHeaders);
FutureOr<gen2.Res<gen3.String>> _$getHeaders(List<dynamic> args) => gen4.getHeaders(args[0], args[1], args[2], args[3]);
const getUntypedResponse_descriptor = gen.RouteDefinition(
    'getUntypedResponse',
    gen1.POST('/untyped'),
    [gen1.POST('/untyped')],
    gen.QualifiedTypeTreeN<gen2.Res<dynamic>, gen2.Res<dynamic>>([gen.QualifiedTerminal<dynamic>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<dynamic>, gen0.Req<dynamic>>([gen.QualifiedTerminal<dynamic>()]), false, 'req', [])
    ],
    _$getUntypedResponse);
FutureOr<gen2.Res<dynamic>> _$getUntypedResponse(List<dynamic> args) => gen4.getUntypedResponse(args[0]);
const getPerson_descriptor = gen.RouteDefinition(
    'getPerson',
    gen1.GET('/person'),
    [gen1.GET('/person')],
    gen.QualifiedTypeTreeN<gen2.Res<gen5.Person>, gen2.Res<dynamic>>([gen.QualifiedTerminal<gen5.Person>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<dynamic>, gen0.Req<dynamic>>([gen.QualifiedTerminal<dynamic>()]), false, 'req', [])
    ],
    _$getPerson);
FutureOr<gen2.Res<gen5.Person>> _$getPerson(List<dynamic> args) => gen4.getPerson(args[0]);
const extractName_descriptor = gen.RouteDefinition(
    'extractName',
    gen1.POST('/person/name'),
    [gen1.POST('/person/name')],
    gen.QualifiedTypeTreeN<gen2.Res<gen3.String>, gen2.Res<dynamic>>([gen.QualifiedTerminal<gen3.String>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<gen5.Person>, gen0.Req<dynamic>>([gen.QualifiedTerminal<gen5.Person>()]), false, 'req', [])
    ],
    _$extractName);
FutureOr<gen2.Res<gen3.String>> _$extractName(List<dynamic> args) => gen4.extractName(args[0]);
const anotherTest_descriptor = gen.RouteDefinition(
    'anotherTest',
    gen1.Route('/anotherTest'),
    [gen1.Route('/anotherTest')],
    gen.QualifiedTypeTreeN<gen2.Res<gen3.String>, gen2.Res<dynamic>>([gen.QualifiedTerminal<gen3.String>()]),
    [
      gen.MethodArgument(gen.QualifiedTypeTreeN<gen0.Req<gen3.String>, gen0.Req<dynamic>>([gen.QualifiedTerminal<gen3.String>()]), false, 'req', [])
    ],
    _$anotherTest);
FutureOr<gen2.Res<gen3.String>> _$anotherTest(List<dynamic> args) => gen4.anotherTest(args[0]);
