import 'package:lyell/lyell.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:reedmace/reedmace.dart';

void main() {
  group("QueryParamArgumentSupplier", () {
    test("Required String Param", () async {
      Reedmace reedmace = Reedmace();
      await reedmace.configure((reedmace) {
        reedmace.sharedLibrary = SharedLibrary.empty();
      });

      final definition = RouteDefinition.create((Req<dynamic> request, args) {
        return Res.ok(args[r"$str"]);
      }, GET("/hello"), request: Req.tree<dynamic>(), response: Res.tree<String>(), args: [
        MethodArgument(QualifiedTypeTree.terminal<String>(), false,r"$str",[])
      ]);
      reedmace.registerRoute(definition);

      var result0 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello?str=world')));
      expect(await result0.readAsString(), "world");
      var result1 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello')));
      expect(result1.statusCode, 400);
    });

    test("Optional String Param", () async {
      Reedmace reedmace = Reedmace();
      await reedmace.configure((reedmace) {
        reedmace.sharedLibrary = SharedLibrary.empty();
      });

      final definition = RouteDefinition.create((Req<dynamic> request, args) {
        return Res.ok(args[r"$str"].toString());
      }, GET("/hello"), request: Req.tree<dynamic>(), response: Res.tree<String>(), args: [
        MethodArgument(QualifiedTypeTree.terminal<String>(), true,r"$str",[])
      ]);
      reedmace.registerRoute(definition);

      var result0 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello?str=world')));
      expect(await result0.readAsString(), "world");
      var result1 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello')));
      expect(await result1.readAsString(), "null");
    });

    test("Required Int Param", () async {
      Reedmace reedmace = Reedmace();
      await reedmace.configure((reedmace) {
        reedmace.sharedLibrary = SharedLibrary.empty();
      });

      final definition = RouteDefinition.create((Req<dynamic> request, args) {
        return Res.ok(args[r"$int"].toString());
      }, GET("/hello"), request: Req.tree<dynamic>(), response: Res.tree<String>(), args: [
        MethodArgument(QualifiedTypeTree.terminal<int>(), false,r"$int",[])
      ]);
      reedmace.registerRoute(definition);

      var result0 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello?int=42')));
      expect(await result0.readAsString(), "42");
      var result1 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello')));
      expect(result1.statusCode, 400);
    });

    test("Optional Int Param", () async {
      Reedmace reedmace = Reedmace();
      await reedmace.configure((reedmace) {
        reedmace.sharedLibrary = SharedLibrary.empty();
      });

      final definition = RouteDefinition.create((Req<dynamic> request, args) {
        return Res.ok(args[r"$int"].toString());
      }, GET("/hello"), request: Req.tree<dynamic>(), response: Res.tree<String>(), args: [
        MethodArgument(QualifiedTypeTree.terminal<int>(), true,r"$int",[])
      ]);
      reedmace.registerRoute(definition);

      var result0 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello?int=42')));
      expect(await result0.readAsString(), "42");
      var result1 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello')));
      expect(await result1.readAsString(), "null");
    });

    test("Required Bool Param", () async {
      Reedmace reedmace = Reedmace();
      await reedmace.configure((reedmace) {
        reedmace.sharedLibrary = SharedLibrary.empty();
      });

      final definition = RouteDefinition.create((Req<dynamic> request, args) {
        return Res.ok(args[r"$bool"].toString());
      }, GET("/hello"), request: Req.tree<dynamic>(), response: Res.tree<String>(), args: [
        MethodArgument(QualifiedTypeTree.terminal<bool>(), false,r"$bool",[])
      ]);
      reedmace.registerRoute(definition);

      var result0 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello?bool=true')));
      expect(await result0.readAsString(), "true");
      var result1 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello')));
      expect(result1.statusCode, 400);
    });

    test("Optional Bool Param", () async {
      Reedmace reedmace = Reedmace();
      await reedmace.configure((reedmace) {
        reedmace.sharedLibrary = SharedLibrary.empty();
      });

      final definition = RouteDefinition.create((Req<dynamic> request, args) {
        return Res.ok(args[r"$bool"].toString());
      }, GET("/hello"), request: Req.tree<dynamic>(), response: Res.tree<String>(), args: [
        MethodArgument(QualifiedTypeTree.terminal<bool>(), true,r"$bool",[])
      ]);
      reedmace.registerRoute(definition);

      var result0 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello?bool=true')));
      expect(await result0.readAsString(), "true");
      var result1 = await reedmace.handle(Request('GET', Uri.parse('http://localhost:8080/hello')));
      expect(await result1.readAsString(), "null");
    });
  });
}