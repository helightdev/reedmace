import 'package:conduit_open_api/v3.dart';
import 'package:lyell/lyell.dart';
import 'package:reedmace/reedmace.dart';

const sse = SseMarker();

class SseMarker implements RetainedAnnotation {
  const SseMarker();
}

class SseInterceptor extends RegistrationInterceptor {
  const SseInterceptor();

  @override
  void modifyDefaultResponse(
      Reedmace reedmace, RouteDefinition definition, APIResponse response) {
    if (definition.annotations.whereType<SseMarker>().isEmpty) return;

    if (definition.innerResponse.typeArgument == dynamic) {
      response.content = {"text/event-stream": APIMediaType.empty()};
    } else {
      var serializer = reedmace.sharedLibrary
          .resolveBodySerializer(definition.innerResponse);
      if (serializer == null) {
        throw StateError(
            "No serializer found for type ${definition.innerResponse}");
      }
      response.content = {
        "text/event-stream": APIMediaType(schema: serializer.getSchema())
          ..extensions = {"x-datastream": true}
      };
    }
  }

  @override
  void postRegistration(Reedmace reedmace, RouteRegistration registration, RouterTerminalNode node) {}
}