// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unused_field, unused_import, public_member_api_docs, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:lyell/lyell.dart' as gen;
import 'package:reedmace_cli/config.dart' as gen0;
import 'dart:core' as gen1;
import 'package:reedmace_cli/config.dart';

class ReedmaceConfigConverter
    extends gen.DefaultStructureConverter<gen0.ReedmaceConfig> {
  ReedmaceConfigConverter()
      : super(
            struct: const gen.DogStructure<gen0.ReedmaceConfig>(
                'ReedmaceConfig',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(
                      gen.QualifiedTerminal<gen0.ReedmaceStructure>(),
                      gen.TypeToken<gen0.ReedmaceStructure>(),
                      null,
                      gen.IterableKind.none,
                      'structure',
                      false,
                      true, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen0.ReedmaceConfig>(
                    _activator, [_$structure], _values)));

  static dynamic _$structure(gen0.ReedmaceConfig obj) => obj.structure;

  static List<dynamic> _values(gen0.ReedmaceConfig obj) => [obj.structure];

  static gen0.ReedmaceConfig _activator(List list) {
    return gen0.ReedmaceConfig(list[0]);
  }
}

class ReedmaceConfigBuilder {
  ReedmaceConfigBuilder([gen0.ReedmaceConfig? $src]) {
    if ($src == null) {
      $values = List.filled(1, null);
    } else {
      $values = ReedmaceConfigConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen0.ReedmaceConfig? $src;

  set structure(gen0.ReedmaceStructure value) {
    $values[0] = value;
  }

  gen0.ReedmaceStructure get structure => $values[0];

  gen0.ReedmaceConfig build() {
    var instance = ReedmaceConfigConverter._activator($values);

    return instance;
  }
}

extension ReedmaceConfigDogsExtension on gen0.ReedmaceConfig {
  gen0.ReedmaceConfig rebuild(Function(ReedmaceConfigBuilder b) f) {
    var builder = ReedmaceConfigBuilder(this);
    f(builder);
    return builder.build();
  }

  ReedmaceConfigBuilder toBuilder() {
    return ReedmaceConfigBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen0.ReedmaceConfig);
  }
}

class ReedmaceStructureConverter
    extends gen.DefaultStructureConverter<gen0.ReedmaceStructure> {
  ReedmaceStructureConverter()
      : super(
            struct: const gen.DogStructure<gen0.ReedmaceStructure>(
                'ReedmaceStructure',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(
                      gen.QualifiedTerminal<gen1.String>(),
                      gen.TypeToken<gen1.String>(),
                      null,
                      gen.IterableKind.none,
                      'server',
                      false,
                      false, []),
                  gen.DogStructureField(
                      gen.QualifiedTerminal<gen1.String>(),
                      gen.TypeToken<gen1.String>(),
                      null,
                      gen.IterableKind.none,
                      'shared_library',
                      false,
                      false, []),
                  gen.DogStructureField(
                      gen.QualifiedTerminal<gen1.String>(),
                      gen.TypeToken<gen1.String>(),
                      null,
                      gen.IterableKind.none,
                      'generated_client',
                      false,
                      false, []),
                  gen.DogStructureField(
                      gen.QualifiedTerminal<gen1.String>(),
                      gen.TypeToken<gen1.String>(),
                      null,
                      gen.IterableKind.none,
                      'application',
                      false,
                      false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen0.ReedmaceStructure>(
                    _activator,
                    [
                      _$server,
                      _$sharedLibrary,
                      _$generatedClient,
                      _$application
                    ],
                    _values)));

  static dynamic _$server(gen0.ReedmaceStructure obj) => obj.server;

  static dynamic _$sharedLibrary(gen0.ReedmaceStructure obj) =>
      obj.sharedLibrary;

  static dynamic _$generatedClient(gen0.ReedmaceStructure obj) =>
      obj.generatedClient;

  static dynamic _$application(gen0.ReedmaceStructure obj) => obj.application;

  static List<dynamic> _values(gen0.ReedmaceStructure obj) =>
      [obj.server, obj.sharedLibrary, obj.generatedClient, obj.application];

  static gen0.ReedmaceStructure _activator(List list) {
    return gen0.ReedmaceStructure(list[0], list[1], list[2], list[3]);
  }
}

class ReedmaceStructureBuilder {
  ReedmaceStructureBuilder([gen0.ReedmaceStructure? $src]) {
    if ($src == null) {
      $values = List.filled(4, null);
    } else {
      $values = ReedmaceStructureConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen0.ReedmaceStructure? $src;

  set server(gen1.String value) {
    $values[0] = value;
  }

  gen1.String get server => $values[0];

  set sharedLibrary(gen1.String value) {
    $values[1] = value;
  }

  gen1.String get sharedLibrary => $values[1];

  set generatedClient(gen1.String value) {
    $values[2] = value;
  }

  gen1.String get generatedClient => $values[2];

  set application(gen1.String value) {
    $values[3] = value;
  }

  gen1.String get application => $values[3];

  gen0.ReedmaceStructure build() {
    var instance = ReedmaceStructureConverter._activator($values);

    return instance;
  }
}

extension ReedmaceStructureDogsExtension on gen0.ReedmaceStructure {
  gen0.ReedmaceStructure rebuild(Function(ReedmaceStructureBuilder b) f) {
    var builder = ReedmaceStructureBuilder(this);
    f(builder);
    return builder.build();
  }

  ReedmaceStructureBuilder toBuilder() {
    return ReedmaceStructureBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen0.ReedmaceStructure);
  }
}

class ServerConfigSectionConverter
    extends gen.DefaultStructureConverter<gen0.ServerConfigSection> {
  ServerConfigSectionConverter()
      : super(
            struct: const gen.DogStructure<gen0.ServerConfigSection>(
                'ServerConfigSection',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(
                      gen.QualifiedTerminal<gen1.String>(),
                      gen.TypeToken<gen1.String>(),
                      null,
                      gen.IterableKind.none,
                      'path',
                      false,
                      false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen0.ServerConfigSection>(
                    _activator, [_$path], _values)));

  static dynamic _$path(gen0.ServerConfigSection obj) => obj.path;

  static List<dynamic> _values(gen0.ServerConfigSection obj) => [obj.path];

  static gen0.ServerConfigSection _activator(List list) {
    return gen0.ServerConfigSection(list[0]);
  }
}

class ServerConfigSectionBuilder {
  ServerConfigSectionBuilder([gen0.ServerConfigSection? $src]) {
    if ($src == null) {
      $values = List.filled(1, null);
    } else {
      $values = ServerConfigSectionConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen0.ServerConfigSection? $src;

  set path(gen1.String value) {
    $values[0] = value;
  }

  gen1.String get path => $values[0];

  gen0.ServerConfigSection build() {
    var instance = ServerConfigSectionConverter._activator($values);

    return instance;
  }
}

extension ServerConfigSectionDogsExtension on gen0.ServerConfigSection {
  gen0.ServerConfigSection rebuild(Function(ServerConfigSectionBuilder b) f) {
    var builder = ServerConfigSectionBuilder(this);
    f(builder);
    return builder.build();
  }

  ServerConfigSectionBuilder toBuilder() {
    return ServerConfigSectionBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen0.ServerConfigSection);
  }
}

class SharedLibraryConfigSectionConverter
    extends gen.DefaultStructureConverter<gen0.SharedLibraryConfigSection> {
  SharedLibraryConfigSectionConverter()
      : super(
            struct: const gen.DogStructure<gen0.SharedLibraryConfigSection>(
                'SharedLibraryConfigSection',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(
                      gen.QualifiedTerminal<gen1.String>(),
                      gen.TypeToken<gen1.String>(),
                      null,
                      gen.IterableKind.none,
                      'path',
                      false,
                      false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<
                        gen0.SharedLibraryConfigSection>(
                    _activator, [_$path], _values)));

  static dynamic _$path(gen0.SharedLibraryConfigSection obj) => obj.path;

  static List<dynamic> _values(gen0.SharedLibraryConfigSection obj) =>
      [obj.path];

  static gen0.SharedLibraryConfigSection _activator(List list) {
    return gen0.SharedLibraryConfigSection(list[0]);
  }
}

class SharedLibraryConfigSectionBuilder {
  SharedLibraryConfigSectionBuilder([gen0.SharedLibraryConfigSection? $src]) {
    if ($src == null) {
      $values = List.filled(1, null);
    } else {
      $values = SharedLibraryConfigSectionConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen0.SharedLibraryConfigSection? $src;

  set path(gen1.String value) {
    $values[0] = value;
  }

  gen1.String get path => $values[0];

  gen0.SharedLibraryConfigSection build() {
    var instance = SharedLibraryConfigSectionConverter._activator($values);

    return instance;
  }
}

extension SharedLibraryConfigSectionDogsExtension
    on gen0.SharedLibraryConfigSection {
  gen0.SharedLibraryConfigSection rebuild(
      Function(SharedLibraryConfigSectionBuilder b) f) {
    var builder = SharedLibraryConfigSectionBuilder(this);
    f(builder);
    return builder.build();
  }

  SharedLibraryConfigSectionBuilder toBuilder() {
    return SharedLibraryConfigSectionBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs
        .convertObjectToNative(this, gen0.SharedLibraryConfigSection);
  }
}

class GeneratedClientConfigSectionConverter
    extends gen.DefaultStructureConverter<gen0.GeneratedClientConfigSection> {
  GeneratedClientConfigSectionConverter()
      : super(
            struct: const gen.DogStructure<gen0.GeneratedClientConfigSection>(
                'GeneratedClientConfigSection',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(
                      gen.QualifiedTerminal<gen1.String>(),
                      gen.TypeToken<gen1.String>(),
                      null,
                      gen.IterableKind.none,
                      'path',
                      false,
                      false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<
                        gen0.GeneratedClientConfigSection>(
                    _activator, [_$path], _values)));

  static dynamic _$path(gen0.GeneratedClientConfigSection obj) => obj.path;

  static List<dynamic> _values(gen0.GeneratedClientConfigSection obj) =>
      [obj.path];

  static gen0.GeneratedClientConfigSection _activator(List list) {
    return gen0.GeneratedClientConfigSection(list[0]);
  }
}

class GeneratedClientConfigSectionBuilder {
  GeneratedClientConfigSectionBuilder(
      [gen0.GeneratedClientConfigSection? $src]) {
    if ($src == null) {
      $values = List.filled(1, null);
    } else {
      $values = GeneratedClientConfigSectionConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen0.GeneratedClientConfigSection? $src;

  set path(gen1.String value) {
    $values[0] = value;
  }

  gen1.String get path => $values[0];

  gen0.GeneratedClientConfigSection build() {
    var instance = GeneratedClientConfigSectionConverter._activator($values);

    return instance;
  }
}

extension GeneratedClientConfigSectionDogsExtension
    on gen0.GeneratedClientConfigSection {
  gen0.GeneratedClientConfigSection rebuild(
      Function(GeneratedClientConfigSectionBuilder b) f) {
    var builder = GeneratedClientConfigSectionBuilder(this);
    f(builder);
    return builder.build();
  }

  GeneratedClientConfigSectionBuilder toBuilder() {
    return GeneratedClientConfigSectionBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs
        .convertObjectToNative(this, gen0.GeneratedClientConfigSection);
  }
}

class ApplicationConfigSectionConverter
    extends gen.DefaultStructureConverter<gen0.ApplicationConfigSection> {
  ApplicationConfigSectionConverter()
      : super(
            struct: const gen.DogStructure<gen0.ApplicationConfigSection>(
                'ApplicationConfigSection',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(
                      gen.QualifiedTerminal<gen1.String>(),
                      gen.TypeToken<gen1.String>(),
                      null,
                      gen.IterableKind.none,
                      'path',
                      false,
                      false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen0.ApplicationConfigSection>(
                    _activator, [_$path], _values)));

  static dynamic _$path(gen0.ApplicationConfigSection obj) => obj.path;

  static List<dynamic> _values(gen0.ApplicationConfigSection obj) => [obj.path];

  static gen0.ApplicationConfigSection _activator(List list) {
    return gen0.ApplicationConfigSection(list[0]);
  }
}

class ApplicationConfigSectionBuilder {
  ApplicationConfigSectionBuilder([gen0.ApplicationConfigSection? $src]) {
    if ($src == null) {
      $values = List.filled(1, null);
    } else {
      $values = ApplicationConfigSectionConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen0.ApplicationConfigSection? $src;

  set path(gen1.String value) {
    $values[0] = value;
  }

  gen1.String get path => $values[0];

  gen0.ApplicationConfigSection build() {
    var instance = ApplicationConfigSectionConverter._activator($values);

    return instance;
  }
}

extension ApplicationConfigSectionDogsExtension
    on gen0.ApplicationConfigSection {
  gen0.ApplicationConfigSection rebuild(
      Function(ApplicationConfigSectionBuilder b) f) {
    var builder = ApplicationConfigSectionBuilder(this);
    f(builder);
    return builder.build();
  }

  ApplicationConfigSectionBuilder toBuilder() {
    return ApplicationConfigSectionBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen0.ApplicationConfigSection);
  }
}
