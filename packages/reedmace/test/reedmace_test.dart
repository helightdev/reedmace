import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';
import 'package:reedmace/reedmace.dart';

void main() {
  group('ReedmaceRouter', () {
    late ReedmaceRouter router;
    late RouteDefinition routeDefinition;

    setUp(() {
      router = ReedmaceRouter();
      router.register(RouteDefinition.dynamicMock('path/hello/world', 'GET').emptyRegistration());
      router.register(RouteDefinition.dynamicMock('path/hello', 'GET').emptyRegistration());
      router.register(RouteDefinition.dynamicMock('path/a', 'GET').emptyRegistration());
      router.register(RouteDefinition.dynamicMock('path/b', 'GET').emptyRegistration());
      router.register(RouteDefinition.dynamicMock('path/c', 'GET').emptyRegistration());
      router.register(RouteDefinition.dynamicMock('path/hello', 'POST').emptyRegistration());
      router.register(RouteDefinition.dynamicMock('path/hello/world', 'ALL').emptyRegistration());
      router.register(RouteDefinition.dynamicMock('path/:hello', 'GET').emptyRegistration());
      router.register(RouteDefinition.dynamicMock('path/:hello/world', 'GET').emptyRegistration());
      router.register(RouteDefinition.dynamicMock('path/:hello/world/:test', 'GET').emptyRegistration());
    });

    test('find returns null when no route matches', () {
      var aUri = Uri.parse("http://localhost:8080/noMatch");
      var bUri = Uri.parse("http://localhost:8080/path/hello");
      var cUri = Uri.parse("http://localhost:8080/path/hello/world/test");
      expect(router.lookup(aUri, "GET"), isNull);
      expect(router.lookup(bUri, "DELETE"), isNull);
      expect(router.lookup(cUri, "DELETE"), isNull);
    });

    test('find returns route when route matches', () {
      var aUri = Uri.parse("http://localhost:8080/path/hello/world");
      var bUri = Uri.parse("http://localhost:8080/path/hello");
      var cUri = Uri.parse("http://localhost:8080/path/hello/world");

      expect(router.lookup(aUri, "GET"), isRouteDefinition("path/hello/world"));
      expect(router.lookup(bUri, "GET"), isRouteDefinition("path/hello"));
      expect(router.lookup(bUri, "POST"), isRouteDefinition("path/hello"));
      expect(router.lookup(cUri, "PATCH"), isRouteDefinition("path/hello/world"));
    });

    test('find returns route when route matches with variable path', () {
      var aUri = Uri.parse("http://localhost:8080/path/variable");
      var bUri = Uri.parse("http://localhost:8080/path/variable/world");
      var cUri = Uri.parse("http://localhost:8080/path/variable/world/test");

      expect(router.lookup(aUri, "GET"), isRouteDefinition("path/:hello"));
      expect(router.lookup(bUri, "GET"), isRouteDefinition("path/:hello/world"));
      expect(router.lookup(cUri, "GET"), isRouteDefinition("path/:hello/world/:test"));
    });

    test('stores correct dynamic segment values', () {
      var result = router.lookup(Uri.parse("http://localhost:8080/path/variable/world/test"), 'GET');
      print(result!.$2);
      expect(result.$2.get("hello"), equals('variable'));
      expect(result.$2.get("test"), equals('test'));
    });
  });
}

Matcher isRouteDefinition(String path) => RouteDefinitionPathMatcher(path);

class RouteDefinitionPathMatcher extends Matcher {
  final String path;

  RouteDefinitionPathMatcher(this.path);

  @override
  bool matches(item, Map matchState) {
    if (item is RouteDefinition) {
      return item.routeAnnotation.path == path;
    } else if (item is (RouteRegistration, Params)) {
      return item.$1.definition.routeAnnotation.path == path;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('RouteDefinition with path: $path');
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription
        .add('was not a RouteDefinition with path: $path');
  }
}
