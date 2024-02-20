import 'dart:io';

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_yaml/dogs_yaml.dart';

ReedmaceConfig readConfig() {
  var configFile = File("reedmace.yaml").readAsStringSync();
  return dogs.yamlDecode<ReedmaceConfig>(configFile);
}

@serializable
class ReedmaceConfig {
  final ReedmaceStructure structure;
  ReedmaceConfig(this.structure);
}

@serializable
class ReedmaceStructure {
  final String server;
  @PropertyName("shared_library")
  final String sharedLibrary;
  @PropertyName("generated_client")
  final String generatedClient;
  final String application;

  ReedmaceStructure(
      this.server, this.sharedLibrary, this.generatedClient, this.application);
}

@serializable
class ServerConfigSection {
  String path;

  ServerConfigSection(this.path);
}

@serializable
class SharedLibraryConfigSection {
  String path;

  SharedLibraryConfigSection(this.path);
}

@serializable
class GeneratedClientConfigSection {
  String path;

  GeneratedClientConfigSection(this.path);
}

@serializable
class ApplicationConfigSection {
  String path;

  ApplicationConfigSection(this.path);
}
