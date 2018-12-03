import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:loft_generator/fields_mapper.dart';
import 'package:recase/recase.dart';
import 'dart:mirrors';

// import 'package:retrofit_generator/src/retrofit_source_class.dart';
import 'package:source_gen/source_gen.dart';
import 'package:loft/src/annotations.dart';

/**
 * THIS SCANS ALL FILES IN PROJECT AND CHECKS IF THIS IS YOUR RetrofitRestService
 * AND RUNS GENERATOR
 */
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
    var types = input.units.expand((CompilationUnitElement cu) {
      if (true) {
        print('asd');
      }
      return cu.types;
    });

    return _buildImplementionClass(annotation, element);
  }
}

String _buildImplementionClass(
  ConstantReader annotation,
  ClassElement element,
) {
  final _dartfmt = new DartFormatter();

//  String a = element.fields.map((e) => e.name).join(', ');

  final classBuilder = Class((c) => c
    ..name = '_\$${element.name}'
    ..extend = Reference(element.name)
    ..methods = ListBuilder(_buildCreateMethod(element)));

  String classString = classBuilder.accept(DartEmitter()).toString();

  String output = _dartfmt.format(classString);

  return output;
}

List _buildCreateMethod(ClassElement element) {
//  var fields = element.fields
//      .map((FieldElement field) =>
//  ReCase(field.name).snakeCase +
//      " " +
//      FieldsMapper().mapDartTypeToSql(field.type.displayName))
//      .join(', ');
//
//  List<Method> methods = [];
//
//  methods.add(Method(
//        (m) => m
//      ..name = "generate"
//      ..body = Code("return 'CREATE TABLE ${element.name} ($fields) ;';")
//      ..returns = Reference('String'),
//  ));
//

  List<Method> methods = [];
  Map<String, String> params = {};

  element.methods.forEach((method) {
    if (method.metadata != null && method.metadata.isNotEmpty) {
      ElementAnnotation meta = method.metadata[0];
      if (meta.constantValue.type.displayName == "Query") {
        var query = meta.constantValue.getField("query").toStringValue();
        print('this is query: $query');

        String queryCode = """
  String path = await getDatabasePath();
  Database database = await openDatabase(path);
  
  var user =   await database.rawQuery("$query")[0];
  

  """;

        methods.add(
          Method(
            (m) => m
              ..requiredParameters = ListBuilder([
                Parameter((b) => b
                  ..name = method.parameters[0].name
                  ..type = Reference(method.parameters[0].type.toString()))
              ])
              ..modifier = MethodModifier.async
              ..name = method.name
              ..returns = Reference(method.returnType.toString())
              ..body = Code(queryCode),
//        ..body = Code(''),
          ),
        );
      }
      if (meta.constantValue.type.displayName == "Insert") {
        MethodElement insertMethods = method;
        DartType methodType = insertMethods.parameters[0].type;
        InstanceMirror reflected = reflect(methodType);
        var ref = reflected.reflectee;

        ref.accessors.forEach((par) {
          params.putIfAbsent(par.variable.name.toString(),
              () => par.variable.type.name.toString());
        });

        var vars = ref.accessors[2].variable;

//insertMethods.parameters[0].name
        var p = insertMethods.parameters[0].name;

        String insertQuery =
            "INSERT INTO ${methodType.name}(${params.keys.join(', ')}) VALUES (${params.keys.map((k) => '\${' + p + "." + k + '}').join((', '))});";

        String insertCode = """
  String path = await getDatabasePath();
  Database database = await openDatabase(path);
  await database.transaction((txn) async {
    await txn.rawInsert("$insertQuery");
  });

  """;

        methods.add(
          Method(
            (m) => m
              ..requiredParameters = ListBuilder([
                Parameter((b) => b
                  ..name = 'user'
                  ..type = Reference('User'))
              ])
              ..modifier = MethodModifier.async
              ..name = insertMethods.name
              ..returns = Reference('void')
              ..body = Code(insertCode),
//        ..body = Code(''),
          ),
        );
      }
    }
  });

//  MethodElement insertMethods = element.methods[0];
//  DartType methodType = insertMethods.parameters[0].type;
//  InstanceMirror reflected = reflect(methodType);
//  var ref = reflected.reflectee;
//
//  ref.accessors.forEach((par) {
//    params.putIfAbsent(
//        par.variable.name.toString(), () => par.variable.type.name.toString());
//  });

//  var ref = reflectClass(methodType.runtimeType);
//ref.accessors[2].variable.type;

  return methods;
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
