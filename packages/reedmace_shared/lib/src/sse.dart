import 'dart:convert';

class SseChunk {
  final String data;
  final String? event;
  final String? id;

  SseChunk(this.data, {this.event, this.id});

  @override
  String toString() {
    final buffer = StringBuffer();
    if (id != null) {
      buffer.writeln('id: $id');
    }
    if (event != null) {
      buffer.writeln('event: $event');
    }
    buffer.writeln('data: $data');
    buffer.writeln();
    return buffer.toString();
  }

  List<int> toBytes() {
    return utf8.encode(toString());
  }
}