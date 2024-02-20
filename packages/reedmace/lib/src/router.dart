
import 'package:reedmace/reedmace.dart';
import 'package:routingkit/routingkit.dart';
import 'package:shelf/shelf.dart';

class RouterTerminalNode {
  Map<String, RouteRegistration> verbs = {};
  RouteRegistration? catchAll;
}

class ReedmaceRouter {
  final _router = TrieRouter<RouterTerminalNode>();
  final Map<String, RouterTerminalNode> apiRoutes = {};

  (RouteRegistration, Params)? handle(Request request) {
    var resolved = lookup(request.url, request.method);
    if (resolved == null) return null;
    return resolved;
  }

  (RouteRegistration, Params)? lookup(Uri uri, String verb) {
    var params = Params();
    var found = _router.lookup(uri.pathSegments, params);
    if (found == null) return null;
    if (found.verbs.containsKey(verb)) return (found.verbs[verb]!, params);
    if (found.catchAll == null) return null;
    return (found.catchAll!, params);
  }

  RouterTerminalNode register(RouteRegistration registration) {
    var path = registration.definition.routeAnnotation.path;
    var segments = path.split("/")
        .where((element) => element.isNotEmpty)
        .map((e) => Segment(e))
        .toList();
    var templatePath = segments.map((e) {
      if (e is ConstSegment) {
        return e.value;
      } else {
        return "0";
      }
    });
    var terminalNode = _router.lookup(templatePath, Params());
    if (terminalNode == null) {
      terminalNode = RouterTerminalNode();
      _router.register(terminalNode, segments);
      apiRoutes[registration.definition.routeAnnotation.openApiPath] = terminalNode;
    }
    if (registration.definition.routeAnnotation.verb == "ALL") {
      terminalNode.catchAll = registration;
    } else {
      terminalNode.verbs[registration.definition.routeAnnotation.verb] = registration;
    }
    return terminalNode;
  }

}