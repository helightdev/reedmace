import 'package:reedmace/reedmace.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test("Test Auth", () async {
    Reedmace reedmace = Reedmace();
    await reedmace.configure((reedmace) {
      reedmace.sharedLibrary = SharedLibrary.empty();

      reedmace.registrationInterceptors
          .add(AuthSchemeInterceptor("Bearer", (token) {
        if (token == "Test") {
          return Principal.simple("0", "Tester", {"projects", "names"});
        }
      }));
    });

    reedmace.registerRoute(RouteDefinition.fromFunction<dynamic, String>((request) {
      return Res.ok("Test");
    }, Route("/hello", verb: "GET"), annotations: [authenticated]));

    var request1 = Request("GET", Uri.parse("http://localhost:8080/hello"));
    var response1 = await reedmace.handle(request1);
    expect(response1.statusCode, 401);

    var request2 = Request("GET", Uri.parse("http://localhost:8080/hello"),
        headers: {"Authorization": "Bearer Test"});
    var response2 = await reedmace.handle(request2);
    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), "Test");

    var request3 = Request("GET", Uri.parse("http://localhost:8080/hello"),
        headers: {"Authorization": "Bearer Invalid"});
    var response3 = await reedmace.handle(request3);
    expect(response3.statusCode, 401);
  });
}
