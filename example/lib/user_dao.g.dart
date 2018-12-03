// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dao.dart';

// **************************************************************************
// LoftDaoGenerator
// **************************************************************************

class _$UserDao extends UserDao {
  User fetch(int id) async {
    String path = await getDatabasePath();
    Database database = await openDatabase(path);

    var user = await database.rawQuery("SELECT * FROM User WHERE id = :id");
  }

  void insert(User user) async {
    String path = await getDatabasePath();
    Database database = await openDatabase(path);
    await database.transaction((txn) async {
      await txn.rawInsert(
          "INSERT INTO User(name, age) VALUES (${user.name}, ${user.age});");
    });
  }
}
