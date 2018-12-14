// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// LoftDatabaseGenerator
// **************************************************************************

class _$TodoDatabase extends TodoDatabase {
  void generate() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "demo.db");

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(User().schema());
    });

    ;
  }

  void drop() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "demo.db");

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(User().drop());
    });
  }
}
