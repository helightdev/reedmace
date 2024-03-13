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

class ReedmaceConfigConverter extends gen.DefaultStructureConverter<gen0.ReedmaceConfig> {
  ReedmaceConfigConverter()
      : super(
            struct: const gen.DogStructure<gen0.ReedmaceConfig>(
                'ReedmaceConfig',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.ReedmaceStructure>(), gen.TypeToken<gen0.ReedmaceStructure>(), null, gen.IterableKind.none, 'structure', false, true, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.DevSettings>(), gen.TypeToken<gen0.DevSettings>(), null, gen.IterableKind.none, 'dev', true, true, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen0.ReedmaceConfig>(_activator, [_$structure, _$dev], _values)));

  static dynamic _$structure(gen0.ReedmaceConfig obj) => obj.structure;

  static dynamic _$dev(gen0.ReedmaceConfig obj) => obj.dev;

  static List<dynamic> _values(gen0.ReedmaceConfig obj) => [obj.structure, obj.dev];

  static gen0.ReedmaceConfig _activator(List list) {
    return gen0.ReedmaceConfig(list[0], list[1]);
  }
}

class ReedmaceConfigBuilder {
  ReedmaceConfigBuilder([gen0.ReedmaceConfig? $src]) {
    if ($src == null) {
      $values = List.filled(2, null);
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

  set dev(gen0.DevSettings? value) {
    $values[1] = value;
  }

  gen0.DevSettings? get dev => $values[1];

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

class ReedmaceStructureConverter extends gen.DefaultStructureConverter<gen0.ReedmaceStructure> {
  ReedmaceStructureConverter()
      : super(
            struct: const gen.DogStructure<gen0.ReedmaceStructure>(
                'ReedmaceStructure',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen1.String>(), gen.TypeToken<gen1.String>(), null, gen.IterableKind.none, 'server', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen1.String>(), gen.TypeToken<gen1.String>(), null, gen.IterableKind.none, 'shared_library', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen1.String>(), gen.TypeToken<gen1.String>(), null, gen.IterableKind.none, 'generated_client', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen1.String>(), gen.TypeToken<gen1.String>(), null, gen.IterableKind.none, 'application', false, false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen0.ReedmaceStructure>(_activator, [_$server, _$sharedLibrary, _$generatedClient, _$application], _values)));

  static dynamic _$server(gen0.ReedmaceStructure obj) => obj.server;

  static dynamic _$sharedLibrary(gen0.ReedmaceStructure obj) => obj.sharedLibrary;

  static dynamic _$generatedClient(gen0.ReedmaceStructure obj) => obj.generatedClient;

  static dynamic _$application(gen0.ReedmaceStructure obj) => obj.application;

  static List<dynamic> _values(gen0.ReedmaceStructure obj) => [obj.server, obj.sharedLibrary, obj.generatedClient, obj.application];

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

class DevSettingsConverter extends gen.DefaultStructureConverter<gen0.DevSettings> {
  DevSettingsConverter()
      : super(
            struct: const gen.DogStructure<gen0.DevSettings>(
                'DevSettings',
                gen.StructureConformity.basic,
                [gen.DogStructureField(gen.QualifiedTerminal<gen1.bool>(), gen.TypeToken<gen1.bool>(), null, gen.IterableKind.none, 'app_build_runner', true, false, [])],
                [],
                gen.ObjectFactoryStructureProxy<gen0.DevSettings>(_activator, [_$appBuildRunner], _values)));

  static dynamic _$appBuildRunner(gen0.DevSettings obj) => obj.appBuildRunner;

  static List<dynamic> _values(gen0.DevSettings obj) => [obj.appBuildRunner];

  static gen0.DevSettings _activator(List list) {
    return gen0.DevSettings(list[0]);
  }
}

class DevSettingsBuilder {
  DevSettingsBuilder([gen0.DevSettings? $src]) {
    if ($src == null) {
      $values = List.filled(1, null);
    } else {
      $values = DevSettingsConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen0.DevSettings? $src;

  set appBuildRunner(gen1.bool? value) {
    $values[0] = value;
  }

  gen1.bool? get appBuildRunner => $values[0];

  gen0.DevSettings build() {
    var instance = DevSettingsConverter._activator($values);

    return instance;
  }
}

extension DevSettingsDogsExtension on gen0.DevSettings {
  gen0.DevSettings rebuild(Function(DevSettingsBuilder b) f) {
    var builder = DevSettingsBuilder(this);
    f(builder);
    return builder.build();
  }

  DevSettingsBuilder toBuilder() {
    return DevSettingsBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen0.DevSettings);
  }
}
