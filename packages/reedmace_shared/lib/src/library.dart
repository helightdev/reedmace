import 'dart:async';

import 'package:lyell/lyell.dart';
import 'package:reedmace_shared/reedmace_shared.dart';

class SharedLibrary {
  final List<ReedmaceSerializerModule> serializerModules = [DefaultReedmaceModule()];
  final FutureOr Function(SharedLibrary library) configureFunction;

  SharedLibrary(this.configureFunction);

  factory SharedLibrary.empty() {
    return SharedLibrary((_) {});
  }

  Future configure() async {
    await configureFunction(this);
    for (var module in serializerModules) {
      await module.configure();
    }
  }

  SharedLibrary addSerializerModule(ReedmaceSerializerModule module) {
    serializerModules.add(module);
    return this;
  }

  ReedmaceBodySerializer? resolveBodySerializer(QualifiedTypeTree type) {
    for (var module in serializerModules) {
      var serializer = module.resolveBodySerializer(type);
      if (serializer != null) {
        return serializer;
      }
    }
    return null;
  }
}