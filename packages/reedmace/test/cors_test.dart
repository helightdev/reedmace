import 'package:reedmace/reedmace.dart';
import 'package:reedmace_shared/reedmace_shared.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test("Test Cors Any", () async {
    Reedmace reedmace = Reedmace();
    await reedmace.configure((reedmace) {
      reedmace.sharedLibrary = SharedLibrary.empty();
    });

    reedmace.registerRoute(RouteDefinition.fromShelf(
        (request) => Response.ok("Test"), GET("/hello")));

    var request1 = Request("OPTIONS", Uri.parse("http://localhost:8080/hello"),
        headers: {"Origin": "http://localhost:8080"});
    var response1 = await reedmace.handle(request1);
    expect(response1.statusCode, 200);
    expect(response1.headers["Access-Control-Allow-Origin"],
        "http://localhost:8080");
    expect(response1.headers["Access-Control-Allow-Methods"],
        "DELETE,GET,OPTIONS,PATCH,POST,PUT");

    // Request without origin
    var request2 = Request("OPTIONS", Uri.parse("http://localhost:8080/hello"));
    var response2 = await reedmace.handle(request2);
    expect(response2.statusCode, 200);
    expect(response2.headers["Access-Control-Allow-Origin"], null);
  });
}
