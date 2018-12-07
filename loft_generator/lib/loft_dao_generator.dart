import 'dart:async';
import 'dart:mirrors';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:loft/src/annotations.dart';
import 'package:source_gen/source_gen.dart';

class LoftDaoGenerator extends GeneratorForAnnotation<Dao> {
  const LoftDaoGenerator();

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement) {
      final friendlyName = element.displayName;
      throw new InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.',
          todo: 'Remove the Entity annotation from `$friendlyName`.');
    }

    var input = await buildStep.inputLibrary;

    return _buildImplementionClass(annotation, element);
  }
}

String _buildImplementionClass(
  ConstantReader annotation,
  ClassElement element,
) {
  final _dartfmt = new DartFormatter();

  final classBuilder = Class((c) => c
    ..name = '_\$${element.name}'
    ..extend = Reference(element.name)
    ..constructors = ListBuilder([
      Constructor((c) => c
        ..initializers = ListBuilder([Code("super._()")])
        ..body = Code(""))
    ])
    ..methods = ListBuilder(_buildCreateMethod(element)));

  String classString = classBuilder.accept(DartEmitter()).toString();

  String output = _dartfmt.format(classString);

  return output;
}

List _buildCreateMethod(ClassElement element) {
  List<Method> methods = [];
  Map<String, String> params = {};

  element.methods.forEach((method) {
    if (method.metadata != null && method.metadata.isNotEmpty) {
      ElementAnnotation meta = method.metadata[0];
      if (meta.constantValue.type.displayName == "Query") {
        var query = meta.constantValue.getField("query").toStringValue();
        print('this is query: $query');
        String queryCode = '';
        if (_isQueryList(method.returnType.toString())) {
          queryCode = """
          String path = await getDatabasePath();
  Database database = await openDatabase(path);
  
    var records = await database.rawQuery("SELECT * FROM User;");
    List<${_typeFromFuture(_typeFromFuture(method.returnType.toString()))}> retRecords = [];
    if (records != null) {
      
      records.forEach((map) {
        retRecords.add(${_typeFromFuture(_typeFromFuture(method.returnType.toString()))}.fromMap(map));
      });
      
      return retRecords;
    }

    return null;
  
          """;
        } else {
          queryCode = """
  String path = await getDatabasePath();
  Database database = await openDatabase(path);
  
    var records = await database.rawQuery("SELECT * FROM User WHERE id = :id;");
    if(records != null && records.length > 0){
      Map<String, dynamic> r = records[0];
      return ${_typeFromFuture(method.returnType.toString())}.fromMap(r);

    }

    return null;
  
  

  """;
        }

        methods.add(
          Method(
            (m) => m
              ..requiredParameters = ListBuilder(method.parameters.length > 0
                  ? [
                      Parameter((b) => b
                        ..name = method.parameters[0].name
                        ..type =
                            Reference(method.parameters[0].type.toString()))
                    ]
                  : [])
              ..modifier = MethodModifier.async
              ..name = method.name
              ..returns = Reference(method.returnType.toString())
              ..body = Code(queryCode),
          ),
        );
      }
      if (meta.constantValue.type.displayName == "Insert") {
        MethodElement insertMethods = method;
        DartType methodType = insertMethods.parameters[0].type;
        InstanceMirror reflected = reflect(methodType);
        var ref = reflected.reflectee;

        ref.accessors.forEach((par) {
          List<ElementAnnotation> metadatas = par.variable.metadata;
          if(metadatas == null || metadatas.length < 1) {
            params.putIfAbsent(par.variable.name.toString(),
                    () => par.variable.type.name.toString());
          }
        });
        var p = insertMethods.parameters[0].name;

        List<String> values = [];
        params.forEach((String key, String value) {
          if (value == 'String') {
            values.add('"' + '\${' + p + "." + key + '}' + '"');
          } else {
            values.add('\${' + p + "." + key + '}');
          }
        });

        String insertValues = values.join(', ');



        params.keys.join(', ');

        String insertQuery =
            "INSERT INTO ${methodType.name}(${params.keys.join(', ')}) VALUES ($insertValues);";

        String insertCode = """
  String path = await getDatabasePath();
  Database database = await openDatabase(path);
  await database.transaction((txn) async {
    await txn.rawInsert('$insertQuery');
  });

  """;

        methods.add(
          Method(
            (m) => m
              ..requiredParameters = ListBuilder([
                Parameter((b) => b
                  ..name = insertMethods.parameters[0].name.toLowerCase()
                  ..type = Reference(insertMethods.parameters[0].type.toString()))
              ])
              ..modifier = MethodModifier.async
              ..name = insertMethods.name
              ..returns = Reference('Future<void>')
              ..body = Code(insertCode),
          ),
        );
      }
    }
  });

  return methods;
}

bool _isQueryList(String type) {
  if (type != null && type.isNotEmpty) {
    String returningType =
        type.substring(type.indexOf('<') + 1, type.length - 1);

    return returningType.length >= 4 && returningType.substring(0, 4) == 'List'
        ? true
        : false;
  } else {
    return false;
  }
}

String _typeFromFuture(String type) {
  return type.substring(type.indexOf('<') + 1, type.length - 1);
}

String _error(Object error) {
  final lines = '$error'.split('\n');
  final indented = lines.skip(1).map((l) => '//        $l'.trim()).join('\n');
  return '// Error: ${lines.first}\n$indented';
}

class QueryMethod {
  Map<String, String> params;

  String returnType;

  String tableName;
}
