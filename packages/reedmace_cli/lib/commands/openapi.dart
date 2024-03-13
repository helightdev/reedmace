import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cancellation_token/cancellation_token.dart';
import 'package:reedmace_cli/actions/build_openapi.dart';
import 'package:reedmace_cli/command.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as path;

class ReedmaceOpenapiCommand extends ReedmaceCommand {
  @override
  String get description =>
      "Commands related to generating OpenAPI documentation";

  @override
  String get name => "openapi";

  ReedmaceOpenapiCommand() {
    addSubcommand(ReedmaceOpenapiBuildCommand());
    addSubcommand(ReedmaceOpenapiServeCommand());
  }

  @override
  Future<int> run() async {
    printUsage();
    return 0;
  }
}

class ReedmaceOpenapiBuildCommand extends ReedmaceCommand {
  @override
  String get description => "Build OpenAPI documentation";

  @override
  String get name => "build";

  ReedmaceOpenapiBuildCommand() {
    argParser.addOption("output", abbr: "o", defaultsTo: "openapi.json");
  }

  @override
  Future<int> run() async {
    await buildOpenapiDocumentProgress(logger, CancellationToken());
    var specs = await getPathFromRoot(path.join(".reedmace", "api_specs.json"))
        .readAsString();

    // Prettify JSON
    JsonEncoder encoder = JsonEncoder.withIndent("  ");
    specs = encoder.convert(json.decode(specs));

    await File(argResults!["output"]!).writeAsString(specs);
    logger
        .success("OpenAPI documentation written to ${argResults!["output"]!}");
    return 0;
  }
}

class ReedmaceOpenapiServeCommand extends ReedmaceCommand {
  @override
  String get description => "Serve OpenAPI documentation locally";

  @override
  String get name => "serve";

  ReedmaceOpenapiServeCommand() {
    argParser.addOption("address", abbr: "a", defaultsTo: "localhost");
    argParser.addOption("port", abbr: "p", defaultsTo: "8080");
  }

  @override
  Future<int> run() async {
    await buildOpenapiDocumentProgress(logger, CancellationToken());
    final specs =
        await getPathFromRoot(path.join(".reedmace", "api_specs.json"))
            .readAsString();
    var swaggerPage = """<html>
    <head>
        <script src="https://unpkg.com/swagger-ui-dist@3/swagger-ui-bundle.js"></script>
        <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@3/swagger-ui.css"/>
        <title>API Docs</title>
    </head>
    <body>
        <div id="swagger-ui"></div> <!-- Div to hold the UI component -->
        <script>
            window.onload = function () {
                // Begin Swagger UI call region
                const ui = SwaggerUIBundle({
                    url: "swagger.json",
                    dom_id: '#swagger-ui',
                    deepLinking: true,
                    presets: [
                        SwaggerUIBundle.presets.apis,
                        SwaggerUIBundle.SwaggerUIStandalonePreset
                    ],
                    plugins: [
                        SwaggerUIBundle.plugins.DownloadUrl
                    ],
                })
                window.ui = ui
            }
        </script>
    </body>
</html>""";

    var router = Router();
    router.get(
        "/",
        (Request request) =>
            Response.ok(swaggerPage, headers: {"Content-Type": "text/html"}));
    router.get(
        "/swagger.json",
        (Request request) =>
            Response.ok(specs, headers: {"Content-Type": "application/json"}));
    logger.success(
        "Serving OpenAPI documentation on http://localhost:${argResults!["port"]!}");
    var server = await io.serve(
        router, argResults!["address"]!, int.parse(argResults!["port"]!));
    await ProcessSignal.sigint.watch().first;
    logger.info("Exiting...");
    server.close(force: true);
    return 0;
  }
}
