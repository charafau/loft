// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dao.dart';

// **************************************************************************
// LoftDaoGenerator
// **************************************************************************

class _$UserDao extends UserDao {
  Future<User> fetch(int id) async {
    String path = await getDatabasePath();
    Database database = await openDatabase(path);

    var records = await database.rawQuery("SELECT * FROM User WHERE id = :id;");
    if (records != null && records.length > 0) {
      Map<String, dynamic> r = records[0];
      return User.fromMap(r);
    }

    return null;
  }

  Future<List<User>> fetchAll() async {
    String path = await getDatabasePath();
    Database database = await openDatabase(path);

    var records = await database.rawQuery("SELECT * FROM User;");
    List<User> retRecords = [];
    if (records != null) {
      records.forEach((map) {
        retRecords.add(User.fromMap(map));
      });

      return retRecords;
    }

    return null;
  }

  Future<void> insert(User user) async {
    String path = await getDatabasePath();
    Database database = await openDatabase(path);
    await database.transaction((txn) async {
      await txn.rawInsert(
          "INSERT INTO User(name, age) VALUES (${user.name}, ${user.age});");
    });
  }
}
