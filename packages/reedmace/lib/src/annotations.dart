import 'package:conduit_open_api/v3.dart';
import 'package:glob/glob.dart';
import 'package:lyell/lyell.dart';
import 'package:recase/recase.dart';
import 'package:reedmace/reedmace.dart';
import 'package:routingkit/routingkit.dart';

class GET extends Route {
  const GET(String path) : super(path, verb: HttpVerb.get);
}

class POST extends Route {
  const POST(String path) : super(path, verb: HttpVerb.post);
}

class PUT extends Route {
  const PUT(String path) : super(path, verb: HttpVerb.put);
}

class DELETE extends Route {
  const DELETE(String path) : super(path, verb: HttpVerb.delete);
}

class PATCH extends Route {
  const PATCH(String path) : super(path, verb: HttpVerb.patch);
}

class Route implements RetainedAnnotation {
  final String path;
  final String verb;

  const Route(this.path, {this.verb = "ALL"});

  List<Segment> get segments {
    var segments = path
        .split("/")
        .where((element) => element.isNotEmpty)
        .map((e) => Segment(e))
        .toList();
    return segments;
  }

  String get openApiPath {
    var wildCardIndex = 0;
    return "/${segments.map((e) => switch (e) {
          ParamSegment() => "{${e.name}}",
          ConstSegment() => e.value,
          AnySegment() => "{wildcard${wildCardIndex++}}",
          CatchallSegment() => "{catchall}"
        }).join("/")}";
  }

  List<String> get pathVariables => RegExp(r':\w+')
      .allMatches(path)
      .map((e) => e.group(0)!.substring(1))
      .toList();

  @override
  String toString() =>
      "${verb.toLowerCase()} ${path.split("/").map((e) => e.replaceFirst(":", "")).join(" ")}"
          .camelCase;

  Route copyWith({String? path, String? verb}) {
    return Route(path ?? this.path, verb: verb ?? this.verb);
  }
}

class HeaderParam extends ArgumentSupplier {
  final String? name;

  const HeaderParam([this.name]);

  @override
  ArgumentFactory? supply(
      MethodArgument argument, Reedmace reedmace, RouteDefinition definition) {
    return switch (argument.nullable) {
      true => (context) =>
          context.request.headers[name ?? argument.name.constantCase],
      false => (context) {
          var header =
              context.request.headers[name ?? argument.name.constantCase];
          if (header == null) {
            throw HttpExceptions.badRequest(
                "Missing required header ${name ?? argument.name.constantCase}");
          }
          return header;
        }
    };
  }

  @override
  void modifyApiOperation(APIOperation operation, MethodArgument argument,
      Reedmace reedmace, RouteDefinition definition) {
    operation.addParameter(APIParameter.header(
        name ?? argument.name.constantCase,
        isRequired: !argument.nullable,
        schema: APISchemaObject.string()));
  }
}

class QueryParam extends ArgumentSupplier {
  final String? name;

  const QueryParam([this.name]);

  @override
  ArgumentFactory? supply(
      MethodArgument argument, Reedmace reedmace, RouteDefinition definition) {
    return switch (argument.nullable) {
      false => (context) {
          var parameter =
              context.queryParameters[name ?? argument.name.snakeCase];
          if (parameter == null) {
            throw HttpExceptions.badRequest(
                "Missing required query parameter ${name ?? argument.name.snakeCase}");
          }
          return parameter;
        },
      true => (context) =>
          context.queryParameters[name ?? argument.name.snakeCase]
    };
  }

  @override
  void modifyApiOperation(APIOperation operation, MethodArgument argument,
      Reedmace reedmace, RouteDefinition definition) {
    operation.addParameter(APIParameter.query(name ?? argument.name.snakeCase,
        isRequired: !argument.nullable, schema: APISchemaObject.string()));
  }
}

class PathParam extends ArgumentSupplier {
  final String? name;

  const PathParam([this.name]);

  @override
  ArgumentFactory? supply(
      MethodArgument argument, Reedmace reedmace, RouteDefinition definition) {
    return (context) => context.pathParams.get(name ?? argument.name);
  }
}

class HttpVerb {
  static const get = "GET";
  static const post = "POST";
  static const put = "PUT";
  static const delete = "DELETE";
  static const patch = "PATCH";
  static const options = "OPTIONS";
  static const head = "HEAD";
  static const trace = "TRACE";

  static const List<String> all = [post, get, patch, put, delete, trace];
  static List<String> getFreeVerbs(Map<String, Object> map) {
    return all.where((element) => !map.containsKey(element)).toList();
  }
}

class ConfigureHook {
  const ConfigureHook();
}

class StartupHook {
  const StartupHook();
}
