import 'package:loft/src/annotations.dart';
import 'package:loft/src/base.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

part 'user.g.dart';

@Entity("users")
class User {
  String name;

  int age;

  User({this.name});

  String schema() => _$User().generate();
}
