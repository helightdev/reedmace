import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:lyell_gen/lyell_gen.dart';

abstract class SimpleAdapter<TAnnotation>
    extends SubjectAdapter<TAnnotation, Element> {
  SimpleAdapter({required super.archetype})
      : super(descriptorExtension: 'reed', annotation: TAnnotation);
}

Directory getNthParent(File file, int n) {
  var parent = file.parent.absolute;
  for (var i = 0; i < n - 1; i++) {
    parent = parent.parent.absolute;
  }
  return parent;
}

