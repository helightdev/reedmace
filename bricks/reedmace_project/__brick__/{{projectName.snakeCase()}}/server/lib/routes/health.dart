import 'package:reedmace/reedmace.dart';

@Route("/health", verb: "GET")
Res<String> health(Req req) {
  return Res.content("Online");
}
