library;

import 'package:reedmace_shared/reedmace_shared.dart';
{{#useDogs}}
import 'package:reedmace_dogs/reedmace_dogs.dart';
import 'package:shared/dogs.g.dart';
{{/useDogs}}

{{#useDogs}}export 'dogs.g.dart';{{/useDogs}}

SharedLibrary get sharedLibrary => SharedLibrary((library) {
  {{#useDogs}}
  library.addSerializerModule(ReedmaceDogsModule(
      converters: sharedConverters
  ));
  {{/useDogs}}
});