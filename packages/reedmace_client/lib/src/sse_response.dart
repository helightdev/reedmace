
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:reedmace_shared/reedmace_shared.dart';

Stream<SseChunk> sseStreamFromResponse(StreamedResponse response) {
  Map<String,String> currentData = {};
  StreamController<SseChunk> controller = StreamController();
  response.stream
      .transform(Utf8Decoder())
      .transform(LineSplitter())
      .listen((event) {

    if (event.isEmpty) {
      controller.add(SseChunk(currentData['data']!, id: currentData['id'], event: currentData['event']));
      currentData.clear();
    } else {
      final colonIndex = event.indexOf(':');
      if (colonIndex == -1 || colonIndex == 0) {
        return;
      }
      final field = event.substring(0, colonIndex);
      final value = event.substring(colonIndex + 1).trim();
      currentData[field] = value;
    }
  }, onDone: controller.close);
  return controller.stream;
}