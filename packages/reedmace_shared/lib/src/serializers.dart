import 'dart:async';
import 'dart:convert';

import 'package:conduit_open_api/v3.dart';
import 'package:lyell/lyell.dart';
import 'package:collection/collection.dart';

abstract class ReedmaceSerializerModule {
  ReedmaceBodySerializer? resolveBodySerializer(QualifiedTypeTree type);

  FutureOr<void> configure() async {}
  void contribute(APIDocument document) {}
}

class OutputDescriptor {
  final Encoding? encoding;
  final String contentType;

  const OutputDescriptor(this.encoding, this.contentType);
}

class DefaultReedmaceModule extends ReedmaceSerializerModule {
  final Map<Type, ReedmaceBodySerializer> serializers = {
    List<int>: IntListSerializer(),
    String: StringSerializer(),
    Map<String, dynamic>: JsonStringSerializer(),
    Map: JsonStringSerializer(),
    dynamic: ReedmaceUnsupportedBodySerializer(),
    (TypeToken<Object?>().typeArgument): ReedmaceUnsupportedBodySerializer(),
  };

  DefaultReedmaceModule();

  @override
  ReedmaceBodySerializer? resolveBodySerializer(QualifiedTypeTree type) {
    var queryableTree = stripFutures(type);
    return serializers[queryableTree.typeArgument];
  }

  static QualifiedTypeTree stripFutures(QualifiedTypeTree type) {
    var baseTypeArgument = type.base.typeArgument;
    if (baseTypeArgument == FutureOr) {
      if (type.arguments.isEmpty) return QualifiedTypeTree.terminal<dynamic>();
      return type.arguments[0] as QualifiedTypeTree;
    } else if (baseTypeArgument == Future) {
      if (type.arguments.isEmpty) return QualifiedTypeTree.terminal<dynamic>();
      return type.arguments[0] as QualifiedTypeTree;
    }
    return type;
  }
}

abstract class ReedmaceBodySerializer {
  Future<dynamic> deserialize(Stream<List<int>> body);

  Object serialize(dynamic object);

  String get identifier => runtimeType.toString();
  OutputDescriptor get descriptor => OutputDescriptor(utf8, "text/plain");

  APISchemaObject? getSchema() => APISchemaObject.freeForm();
}

class ReedmaceUnsupportedBodySerializer extends ReedmaceBodySerializer {
  @override
  String get identifier => "none";

  @override
  APISchemaObject? getSchema() => null;

  @override
  Future<dynamic> deserialize(Stream<List<int>> body) async {
    throw UnsupportedError("This serializer does not support deserialization");
  }

  @override
  Object serialize(dynamic object) {
    throw UnsupportedError("This serializer does not support serialization");
  }
}

abstract class ReedmaceUtf8Serializer extends ReedmaceBodySerializer {
  final String contentType;

  ReedmaceUtf8Serializer(this.contentType);

  @override
  Future<dynamic> deserialize(Stream<List<int>> body) async {
    var str = await utf8.decodeStream(body);
    return deserializeString(str);
  }

  @override
  Object serialize(dynamic object) {
    return serializeString(object);
  }

  dynamic deserializeString(String string);

  String serializeString(dynamic object);
}

class IntListSerializer extends ReedmaceBodySerializer {
  @override
  String get identifier => "Binary";

  @override
  APISchemaObject getSchema() => APISchemaObject.file();

  @override
  Future<List<int>> deserialize(Stream<List<int>> body) =>
      body.expand((element) => element).toList();

  @override
  OutputDescriptor get descriptor =>
      OutputDescriptor(utf8, "application/octet-stream");

  @override
  Object serialize(object) {
    if (object is List<int>) {
      return object;
    } else {
      throw ArgumentError('Expected List<int> but got ${object.runtimeType}');
    }
  }
}

class StringSerializer extends ReedmaceUtf8Serializer {
  StringSerializer() : super("text/plain");

  @override
  String get identifier => "String";

  @override
  APISchemaObject getSchema() => APISchemaObject.string();

  @override
  dynamic deserializeString(String string) => string;

  @override
  String serializeString(dynamic object) => object as String;
}

class JsonStringSerializer extends ReedmaceUtf8Serializer {
  JsonStringSerializer() : super("application/json");

  @override
  String get identifier => "Json";

  @override
  APISchemaObject getSchema() => APISchemaObject.freeForm();

  @override
  dynamic deserializeString(String string) => json.decode(string);

  @override
  String serializeString(dynamic object) => json.encode(object);
}

class JsonToMapSerializer<T> extends ReedmaceUtf8Serializer {
  @override
  String get identifier => "JsonMap";

  @override
  APISchemaObject getSchema() => APISchemaObject.freeForm();

  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;

  JsonToMapSerializer(this.fromMap, this.toMap) : super("application/json");

  @override
  dynamic deserializeString(String string) => fromMap(json.decode(string));

  @override
  String serializeString(dynamic object) => json.encode(toMap(object));
}
