library;

import 'package:reedmace_dogs/reedmace_dogs.dart';
import 'package:reedmace_shared/reedmace_shared.dart';
import 'package:shared/dogs.g.dart';

export 'dogs.g.dart';
export 'models.dart';

SharedLibrary get sharedLibrary => SharedLibrary((library) {
      library.addSerializerModule(
          ReedmaceDogsModule(converters: sharedConverters));
    });
