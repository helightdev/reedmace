import 'package:api_client/main.dart';
import 'package:reedmace_client/reedmace_client.dart';
import 'package:shared/models.dart';
import 'package:shared/shared.dart';

Future main() async {
  await ReedmaceClient.configure(sharedLibrary: sharedLibrary);
  print(await sync());
  print(await getTest());
  print(await getQuery($skip: "1", $limit: "2"));
  print(await postTest("Test"));
  print(await getUser("body"));
  print((await getUntypedResponse()).statusCode);
  print(await getPerson());
  print(await extractName(Person("Mannie", 60, "mammoth")));
  print(await anotherTest("body"));
}