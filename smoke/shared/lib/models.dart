
import 'package:dogs_core/dogs_core.dart';

@serializable
class Person with Dataclass<Person>{
  String name;
  int age;
  String tag;

  Person(this.name, this.age, this.tag);
}