import 'package:dogs_core/dogs_core.dart';
import 'package:reedmace/reedmace.dart';
import 'package:shared/dogs.g.dart';
import 'package:shared/shared.dart';

@ConfigureHook()
Future configure(Reedmace reedmace) async {
  DogEngine().setSingleton();
  installSharedConverters();
  reedmace.sharedLibrary = sharedLibrary;
}
