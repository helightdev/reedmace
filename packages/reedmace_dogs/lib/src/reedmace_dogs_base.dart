import 'package:conduit_open_api/v3.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:lyell/src/qualified_tree.dart';
import 'package:reedmace_shared/reedmace_shared.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class ReedmaceDogsModule extends ReedmaceSerializerModule {
  DogEngine? engine;
  List<DogConverter> converters = [];

  ReedmaceDogsModule({DogEngine? engine, this.converters = const []}) {
    if (engine != null) {
      this.engine = engine;
    }
  }

  Set<ReedmaceBodySerializer> createdSerializers = {};

  @override
  Future configure() async {
    if (engine == null) {
      if (!DogEngine.hasValidInstance) {
        print("DogEngine is not set, setting default instance."
            "Normally you should initialize the DogEngine instance yourself.");
        DogEngine().setSingleton();
      }
      engine = DogEngine.instance;
    }
    engine!.registerAllConverters(converters);
  }

  @override
  void contribute(APIDocument document) {
    var schema = DogSchema.create();
    var generatedSchemas = schema.getApiDocument().components!.schemas;
    document.components!.schemas.addAll(generatedSchemas);
  }

  @override
  ReedmaceBodySerializer? resolveBodySerializer(QualifiedTypeTree type) {
    try {
      var treeConverter = engine!.getTreeConverter(type);
      var serializer = DogsConverterSerializer(engine!, type, treeConverter);
      createdSerializers.add(serializer);
      return serializer;
    } catch (e) {
      print("Dogs can't resolve $type");
      return null;
    }
  }
}

class DogsConverterSerializer extends ReedmaceUtf8Serializer {
  final DogEngine engine;
  final QualifiedTypeTree tree;
  final DogConverter converter;

  final String id = Uuid().v4();

  @override
  String get identifier => id;

  @override
  APISchemaObject? getSchema() => converter.output;

  DogsConverterSerializer(this.engine, this.tree, this.converter)
      : super("application/json");

  @override
  deserializeString(String string) {
    return engine.fromJson(string, tree: tree);
  }

  @override
  String serializeString(object) {
    return engine.toJson(object, tree: tree);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogsConverterSerializer &&
          runtimeType == other.runtimeType &&
          tree.typeArgument == other.tree.typeArgument;

  @override
  int get hashCode => tree.typeArgument.hashCode;
}
