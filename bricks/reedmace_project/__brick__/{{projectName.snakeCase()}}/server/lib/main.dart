import 'package:reedmace/reedmace.dart';
import 'package:shared/shared.dart';

Future configure(Reedmace reedmace) async {
  reedmace.sharedLibrary = sharedLibrary;
}