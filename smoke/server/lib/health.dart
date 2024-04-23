import 'package:reedmace/reedmace.dart';

@Route("/health", verb: "GET")
Res<String> health(Req req) {
  return Res.content("Online");
}

@GET("/health-stream")
@sse
Res healthStream(Req req) {
  return Res.sse(create: () async* {
    yield SseChunk("Hello", id: "wait-for-it");
    await Future.delayed(Duration(seconds: 1));
    yield SseChunk("World");

  });
}