class FieldsMapper {
  Map<String, String> _typeMap = {
    'int': 'INTEGER',
    'String': 'TEXT',
    'double': 'REAL',
    'float': 'REAL',
    'bool': 'INTEGER',
  };

  String mapDartTypeToSql(String dartType) => _typeMap[dartType];
}
