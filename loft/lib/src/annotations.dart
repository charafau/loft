import 'package:meta/meta.dart';

@immutable
class Entity {
  final String tableName;

  const Entity(this.tableName);
}

@immutable
class PrimaryKey {
  const PrimaryKey();
}

@immutable
class ColumnInfo {
  final String name;

  const ColumnInfo(this.name);
}

@immutable
class Dao {
  const Dao();
}

@immutable
class Query {
  final String query;

  const Query(this.query);
}

@immutable
class Insert {
  const Insert();
}

@immutable
class Update {}

@immutable
class Delete {}

@immutable
class LoftDb {
  final String databaseName;
  final int version;
  final List<Type> entities;

  const LoftDb(this.databaseName, {@required this.entities, this.version = 1});
}
