import 'dart:core';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:reedmace_client/reedmace_client.dart';
import 'package:http/http.dart' as http;
import 'package:lyell/lyell.dart' as gen;
import 'dart:core' as gen0;
import 'package:shared/models.dart' as gen1;

Future<http.Response> getUntypedResponse(
    {dynamic body, Encoding? encoding}) async {
  var path = '/untyped';
  var queryParameters = <String, String>{};
  var headerParameters = <String, String>{};

  return ReedmaceClient.global
      .send<dynamic>('POST', path,
          body: body,
          encoding: encoding,
          hasBody: false,
          hasTypedResponse: false,
          reqBodyIdentifier: gen.QualifiedTerminal<dynamic>(),
          resBodyIdentifier: gen.QualifiedTerminal<dynamic>(),
          queryParameters: queryParameters,
          headerParameters: headerParameters)
      .then((e) => e! as http.Response);
}

Future<gen0.String?> health({dynamic body, Encoding? encoding}) async {
  var path = '/health';
  var queryParameters = <String, String>{};
  var headerParameters = <String, String>{};

  return ReedmaceClient.global.send<gen0.String>('GET', path,
      body: body,
      encoding: encoding,
      hasBody: false,
      hasTypedResponse: true,
      reqBodyIdentifier: gen.QualifiedTerminal<dynamic>(),
      resBodyIdentifier: gen.QualifiedTerminal<gen0.String>(),
      queryParameters: queryParameters,
      headerParameters: headerParameters);
}

Future<gen0.String?> sync({dynamic body, Encoding? encoding}) async {
  var path = '/sync';
  var queryParameters = <String, String>{};
  var headerParameters = <String, String>{};

  return ReedmaceClient.global.send<gen0.String>('GET', path,
      body: body,
      encoding: encoding,
      hasBody: false,
      hasTypedResponse: true,
      reqBodyIdentifier: gen.QualifiedTerminal<dynamic>(),
      resBodyIdentifier: gen.QualifiedTerminal<gen0.String>(),
      queryParameters: queryParameters,
      headerParameters: headerParameters);
}

Future<gen0.String?> getTest({dynamic body, Encoding? encoding}) async {
  var path = '/test';
  var queryParameters = <String, String>{};
  var headerParameters = <String, String>{};

  return ReedmaceClient.global.send<gen0.String>('GET', path,
      body: body,
      encoding: encoding,
      hasBody: false,
      hasTypedResponse: true,
      reqBodyIdentifier: gen.QualifiedTerminal<dynamic>(),
      resBodyIdentifier: gen.QualifiedTerminal<gen0.String>(),
      queryParameters: queryParameters,
      headerParameters: headerParameters);
}

Future<gen0.String?> getUser(String id,
    {dynamic body, Encoding? encoding}) async {
  var path = '/user/{id}'.replaceFirst('{id}', id);
  var queryParameters = <String, String>{};
  var headerParameters = <String, String>{};

  return ReedmaceClient.global.send<gen0.String>('GET', path,
      body: body,
      encoding: encoding,
      hasBody: false,
      hasTypedResponse: true,
      reqBodyIdentifier: gen.QualifiedTerminal<dynamic>(),
      resBodyIdentifier: gen.QualifiedTerminal<gen0.String>(),
      queryParameters: queryParameters,
      headerParameters: headerParameters);
}

Future<gen0.String?> getQuery(
    {dynamic body,
    Encoding? encoding,
    required String $skip,
    String? $limit}) async {
  var path = '/query';
  var queryParameters = <String, String>{};
  var headerParameters = <String, String>{};
  queryParameters['skip'] = $skip;
  if ($limit != null) queryParameters['limit'] = $limit;

  return ReedmaceClient.global.send<gen0.String>('GET', path,
      body: body,
      encoding: encoding,
      hasBody: false,
      hasTypedResponse: true,
      reqBodyIdentifier: gen.QualifiedTerminal<dynamic>(),
      resBodyIdentifier: gen.QualifiedTerminal<gen0.String>(),
      queryParameters: queryParameters,
      headerParameters: headerParameters);
}

Future<gen0.String?> getHeaders(
    {dynamic body,
    Encoding? encoding,
    required String $$Authorization,
    String? $$A,
    String? $$B}) async {
  var path = '/headers';
  var queryParameters = <String, String>{};
  var headerParameters = <String, String>{};
  headerParameters['Authorization'] = $$Authorization;
  if ($$A != null) headerParameters['A'] = $$A;
  if ($$B != null) headerParameters['B'] = $$B;

  return ReedmaceClient.global.send<gen0.String>('GET', path,
      body: body,
      encoding: encoding,
      hasBody: false,
      hasTypedResponse: true,
      reqBodyIdentifier: gen.QualifiedTerminal<dynamic>(),
      resBodyIdentifier: gen.QualifiedTerminal<gen0.String>(),
      queryParameters: queryParameters,
      headerParameters: headerParameters);
}

Future<gen0.String?> postTest(gen0.String body) async {
  var path = '/test';
  var queryParameters = <String, String>{};
  var headerParameters = <String, String>{};

  return ReedmaceClient.global.send<gen0.String>('POST', path,
      body: body,
      encoding: null,
      hasBody: true,
      hasTypedResponse: true,
      reqBodyIdentifier: gen.QualifiedTerminal<gen0.String>(),
      resBodyIdentifier: gen.QualifiedTerminal<gen0.String>(),
      queryParameters: queryParameters,
      headerParameters: headerParameters);
}

Future<gen0.String?> anotherTest(gen0.String body) async {
  var path = '/anotherTest';
  var queryParameters = <String, String>{};
  var headerParameters = <String, String>{};

  return ReedmaceClient.global.send<gen0.String>('POST', path,
      body: body,
      encoding: null,
      hasBody: true,
      hasTypedResponse: true,
      reqBodyIdentifier: gen.QualifiedTerminal<gen0.String>(),
      resBodyIdentifier: gen.QualifiedTerminal<gen0.String>(),
      queryParameters: queryParameters,
      headerParameters: headerParameters);
}

Future<gen0.String?> extractName(gen1.Person body) async {
  var path = '/person/name';
  var queryParameters = <String, String>{};
  var headerParameters = <String, String>{};

  return ReedmaceClient.global.send<gen0.String>('POST', path,
      body: body,
      encoding: null,
      hasBody: true,
      hasTypedResponse: true,
      reqBodyIdentifier: gen.QualifiedTerminal<gen1.Person>(),
      resBodyIdentifier: gen.QualifiedTerminal<gen0.String>(),
      queryParameters: queryParameters,
      headerParameters: headerParameters);
}

Future<gen1.Person?> getPerson({dynamic body, Encoding? encoding}) async {
  var path = '/person';
  var queryParameters = <String, String>{};
  var headerParameters = <String, String>{};

  return ReedmaceClient.global.send<gen1.Person>('GET', path,
      body: body,
      encoding: encoding,
      hasBody: false,
      hasTypedResponse: true,
      reqBodyIdentifier: gen.QualifiedTerminal<dynamic>(),
      resBodyIdentifier: gen.QualifiedTerminal<gen1.Person>(),
      queryParameters: queryParameters,
      headerParameters: headerParameters);
}
