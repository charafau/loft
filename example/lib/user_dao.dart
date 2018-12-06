import 'package:example/user.dart';
import 'package:loft/src/annotations.dart';
import 'package:loft/src/base.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

part 'user_dao.g.dart';

@Dao()
abstract class UserDao extends BaseDao {
  @Query('SELECT * FROM User WHERE id = :id')
  Future<User> fetch(int id);

  @Query('SELECT * FROM User')
  Future<List<User>> fetchAll();

  @Insert()
  void insert(User user);

  @override
  Future<String> getDatabasePath() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');
    return path;
  }

  UserDao._();

  factory UserDao() = _$UserDao;
}
