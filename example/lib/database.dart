import 'package:example/user.dart';
import 'package:loft/src/base.dart';
import 'package:loft/src/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


part 'database.g.dart';

@LoftDb('todo.db', entities: [User])
abstract class TodoDatabase extends LoftDatabase {


//  TodoDao todoDao();

}
