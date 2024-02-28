import 'dart:core';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:reedmace_client/reedmace_client.dart';
import 'package:http/http.dart' as http;
import 'package:lyell/lyell.dart' as gen;
import 'dart:core' as gen0;
import 'package:shared/models.dart' as gen1;

class Reedmace {
  Reedmace._();

// Method Definitions
  static const ReedmaceClientMethod<http.Response> $getUntypedResponse =
      ReedmaceClientMethod(
    'POST',
    '/untyped',
    false,
    false,
    gen.QualifiedTerminal<dynamic>(),
    gen.QualifiedTerminal<dynamic>(),
  );

  static const ReedmaceClientMethod<gen0.String> $health = ReedmaceClientMethod(
    'GET',
    '/health',
    false,
    true,
    gen.QualifiedTerminal<dynamic>(),
    gen.QualifiedTerminal<gen0.String>(),
  );

  static const ReedmaceClientMethod<gen0.String> $sync = ReedmaceClientMethod(
    'GET',
    '/sync',
    false,
    true,
    gen.QualifiedTerminal<dynamic>(),
    gen.QualifiedTerminal<gen0.String>(),
  );

  static const ReedmaceClientMethod<gen0.String> $getTest =
      ReedmaceClientMethod(
    'GET',
    '/test',
    false,
    true,
    gen.QualifiedTerminal<dynamic>(),
    gen.QualifiedTerminal<gen0.String>(),
  );

  static const ReedmaceClientMethod<gen0.String> $getUser =
      ReedmaceClientMethod(
    'GET',
    '/user/{id}',
    false,
    true,
    gen.QualifiedTerminal<dynamic>(),
    gen.QualifiedTerminal<gen0.String>(),
  );

  static const ReedmaceClientMethod<gen0.String> $getQuery =
      ReedmaceClientMethod(
    'GET',
    '/query',
    false,
    true,
    gen.QualifiedTerminal<dynamic>(),
    gen.QualifiedTerminal<gen0.String>(),
  );

  static const ReedmaceClientMethod<gen0.String> $getHeaders =
      ReedmaceClientMethod(
    'GET',
    '/headers',
    false,
    true,
    gen.QualifiedTerminal<dynamic>(),
    gen.QualifiedTerminal<gen0.String>(),
  );

  static const ReedmaceClientMethod<gen0.String> $postTest =
      ReedmaceClientMethod(
    'POST',
    '/test',
    true,
    true,
    gen.QualifiedTerminal<gen0.String>(),
    gen.QualifiedTerminal<gen0.String>(),
  );

  static const ReedmaceClientMethod<gen0.String> $anotherTest =
      ReedmaceClientMethod(
    'GET',
    '/anotherTest',
    true,
    true,
    gen.QualifiedTerminal<gen0.String>(),
    gen.QualifiedTerminal<gen0.String>(),
  );

  static const ReedmaceClientMethod<gen0.String> $anotherTest2 =
      ReedmaceClientMethod(
    'GET',
    '/anotherTest2',
    true,
    true,
    gen.QualifiedTerminal<gen0.String>(),
    gen.QualifiedTerminal<gen0.String>(),
  );

  static const ReedmaceClientMethod<gen0.String> $extractName =
      ReedmaceClientMethod(
    'POST',
    '/person/name',
    true,
    true,
    gen.QualifiedTerminal<gen1.Person>(),
    gen.QualifiedTerminal<gen0.String>(),
  );

  static const ReedmaceClientMethod<gen1.Person> $getPerson =
      ReedmaceClientMethod(
    'GET',
    '/person',
    false,
    true,
    gen.QualifiedTerminal<dynamic>(),
    gen.QualifiedTerminal<gen1.Person>(),
  );

// Method Invocations
  static ReedmaceClientMethodInvocation<http.Response> getUntypedResponse(
      {dynamic body, Encoding? encoding, ReedmaceClient? client}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};

    return $getUntypedResponse.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: encoding,
        pathParameters: {},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  static ReedmaceClientMethodInvocation<gen0.String> health(
      {dynamic body, Encoding? encoding, ReedmaceClient? client}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};

    return $health.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: encoding,
        pathParameters: {},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  static ReedmaceClientMethodInvocation<gen0.String> sync(
      {dynamic body, Encoding? encoding, ReedmaceClient? client}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};

    return $sync.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: encoding,
        pathParameters: {},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  static ReedmaceClientMethodInvocation<gen0.String> getTest(
      {dynamic body, Encoding? encoding, ReedmaceClient? client}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};

    return $getTest.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: encoding,
        pathParameters: {},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  static ReedmaceClientMethodInvocation<gen0.String> getUser(String id,
      {dynamic body, Encoding? encoding, ReedmaceClient? client}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};

    return $getUser.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: encoding,
        pathParameters: {'id': id},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  static ReedmaceClientMethodInvocation<gen0.String> getQuery(
      {dynamic body,
      Encoding? encoding,
      ReedmaceClient? client,
      required int $skip,
      int? $limit}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};
    queryParameters['skip'] = ($skip).toString();
    if ($limit != null) queryParameters['limit'] = ($limit).toString();

    return $getQuery.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: encoding,
        pathParameters: {},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  static ReedmaceClientMethodInvocation<gen0.String> getHeaders(
      {dynamic body,
      Encoding? encoding,
      ReedmaceClient? client,
      required String $$Authorization,
      String? $$A,
      String? $$B}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};
    headerParameters['Authorization'] = $$Authorization;
    if ($$A != null) headerParameters['A'] = $$A;
    if ($$B != null) headerParameters['B'] = $$B;

    return $getHeaders.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: encoding,
        pathParameters: {},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  static ReedmaceClientMethodInvocation<gen0.String> postTest(gen0.String body,
      {ReedmaceClient? client}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};

    return $postTest.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: null,
        pathParameters: {},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  static ReedmaceClientMethodInvocation<gen0.String> anotherTest(
      gen0.String body,
      {ReedmaceClient? client}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};

    return $anotherTest.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: null,
        pathParameters: {},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  static ReedmaceClientMethodInvocation<gen0.String> anotherTest2(
      gen0.String body,
      {ReedmaceClient? client}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};

    return $anotherTest2.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: null,
        pathParameters: {},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  static ReedmaceClientMethodInvocation<gen0.String> extractName(
      gen1.Person body,
      {ReedmaceClient? client}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};

    return $extractName.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: null,
        pathParameters: {},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }

  static ReedmaceClientMethodInvocation<gen1.Person> getPerson(
      {dynamic body, Encoding? encoding, ReedmaceClient? client}) {
    var queryParameters = <String, String>{};
    var headerParameters = <String, String>{};

    return $getPerson.createInvocation(
        client: client ?? ReedmaceClient.global,
        body: body,
        encoding: encoding,
        pathParameters: {},
        queryParameters: queryParameters,
        headerParameters: headerParameters);
  }
}
