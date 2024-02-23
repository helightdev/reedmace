import 'package:api_client/main.dart';
import 'package:reedmace_client/reedmace_client.dart';
import 'package:shared/models.dart';
import 'package:shared/shared.dart';

Future main() async {
  await ReedmaceClient.configure(sharedLibrary: sharedLibrary);
  print(await Reedmace.sync());
  print(await Reedmace.getTest());
  print(await Reedmace.getQuery($skip: 1, $limit: 2));
  print(await Reedmace.postTest("Test"));
  print(await Reedmace.getUser("body"));
  print((await Reedmace.getUntypedResponse()).statusCode);
  print(await Reedmace.getPerson());
  print(await Reedmace.extractName(Person("Mannie", 60, "mammoth")));
  print(await Reedmace.anotherTest("body"));
}
