import 'package:meta/meta.dart';

@immutable
class Entity {
  final String tableName;

  const Entity(this.tableName);
}

@immutable
class PrimaryKey {}

@immutable
class ColumnInfo {
  final String name;

  const ColumnInfo(this.name);
}

@immutable
class Dao {}

@immutable
class Query {
  final String query;

  Query(this.query);
}

@immutable
class Insert {}

@immutable
class Update {}

@immutable
class Delete {}
