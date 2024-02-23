// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unused_field, unused_import, public_member_api_docs, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:lyell/lyell.dart' as gen;
import 'dart:core' as gen0;
import 'package:shared/models.dart' as gen1;
import 'package:shared/models.dart';

class PersonConverter extends gen.DefaultStructureConverter<gen1.Person> {
  PersonConverter()
      : super(
            struct: const gen.DogStructure<gen1.Person>(
                'Person',
                gen.StructureConformity.dataclass,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'name', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'age', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'tag', false, false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen1.Person>(_activator, [_$name, _$age, _$tag], _values, _hash, _equals)));

  static dynamic _$name(gen1.Person obj) => obj.name;

  static dynamic _$age(gen1.Person obj) => obj.age;

  static dynamic _$tag(gen1.Person obj) => obj.tag;

  static List<dynamic> _values(gen1.Person obj) => [obj.name, obj.age, obj.tag];

  static gen1.Person _activator(List list) {
    return gen1.Person(list[0], list[1], list[2]);
  }

  static int _hash(gen1.Person obj) => obj.name.hashCode ^ obj.age.hashCode ^ obj.tag.hashCode;

  static bool _equals(
    gen1.Person a,
    gen1.Person b,
  ) =>
      (a.name == b.name && a.age == b.age && a.tag == b.tag);
}

class PersonBuilder {
  PersonBuilder([gen1.Person? $src]) {
    if ($src == null) {
      $values = List.filled(3, null);
    } else {
      $values = PersonConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen1.Person? $src;

  set name(gen0.String value) {
    $values[0] = value;
  }

  gen0.String get name => $values[0];

  set age(gen0.int value) {
    $values[1] = value;
  }

  gen0.int get age => $values[1];

  set tag(gen0.String value) {
    $values[2] = value;
  }

  gen0.String get tag => $values[2];

  gen1.Person build() {
    var instance = PersonConverter._activator($values);

    return instance;
  }
}

extension PersonDogsExtension on gen1.Person {
  gen1.Person rebuild(Function(PersonBuilder b) f) {
    var builder = PersonBuilder(this);
    f(builder);
    return builder.build();
  }

  PersonBuilder toBuilder() {
    return PersonBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen1.Person);
  }
}
