import 'package:loft/src/annotations.dart';

part 'user.g.dart';

@Entity("users")
class User {

  @PrimaryKey()
  int id;

  String name;

  int age;

  User({this.name, this.age});

  String schema() => _$User().generate();

  String drop() => _$User().drop();

  User.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    age = map['age'];
  }

  @override
  String toString() {
    return 'User{name: $name, age: $age}';
  }
}
