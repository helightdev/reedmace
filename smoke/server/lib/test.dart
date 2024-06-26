import 'package:reedmace/reedmace.dart';
import 'package:shared/models.dart';

@GET('/sync')
Res<String> sync(Req req) {
  return Res.ok("Hello World!");
}


@GET('/test')
Future<Res<String>> getTest(Req req) async {
  return Res.content("Hello World!");
}

@POST('/test')
Future<Res<String>> postTest(Req<String> req) async {
  return Res.content("Hello (post) '${await req.receive()}'!");
}

@GET('/user/:id')
Future<Res<String>> getUser(Req req, String id) async {
  return Res.content("Hello User '$id'!");
}

@GET('/query')
Future<Res<String>> getQuery(Req req, int $skip, int? $limit) async {
  return Res.content("Query: ${$skip}, ${$limit}");
}

@GET('/headers')
Future<Res<String>> getHeaders(Req req, String $$Authorization,
    @HeaderParam("A") String? a, @HeaderParam() String? b) async {
  return Res.content("Authorization: ${$$Authorization}, $a, $b");
}

@POST('/untyped')
Future<Res> getUntypedResponse(Req req) async {
  return Res.content("Hello World!");
}

// Person
@GET('/person')
Future<Res<Person>> getPerson(Req req) async {
  return Res.content(Person("Alex", 25, "male"));
}

@POST('/personStream')
@sse Res<Person> getPersonStream(Req req) {
  return Res.sse(create: () async* {
    yield Person("Alex", 25, "male");
    await Future.delayed(Duration(seconds: 1));
    yield Person("Emily", 30, "female");
  });
}

@POST('/person/name')
Res<String> extractName(ValReq<Person> req) {
  return Res.ok(req.value.name);
}

@GET("/anotherTest")
Future<Res<String>> anotherTest(Req<String> req) async {
  return Res.content("Another test: ${await req.receive()}+1");
}

@GET("/anotherTest2")
Future<Res<String>> anotherTest2(Req<String> req) async {
  return Res.content("Another test: ${await req.receive()}+2");
}