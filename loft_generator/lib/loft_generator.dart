import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:loft_generator/fields_mapper.dart';
import 'package:recase/recase.dart';

// import 'package:retrofit_generator/src/retrofit_source_class.dart';
import 'package:source_gen/source_gen.dart';
import 'package:loft/src/annotations.dart';

/**
 * THIS SCANS ALL FILES IN PROJECT AND CHECKS IF THIS IS YOUR RetrofitRestService
 * AND RUNS GENERATOR
 */
class LoftGenerator extends GeneratorForAnnotation<Entity> {
  const LoftGenerator();

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      final friendlyName = element.displayName;
      throw new InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.',
          todo: 'Remove the Entity annotation from `$friendlyName`.');
    }

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
  var fields = element.fields
      .map((FieldElement field) =>
          ReCase(field.name).snakeCase +
          " " +
          FieldsMapper().mapDartTypeToSql(field.type.displayName))
      .join(', ');

  List<Method> methods = [];

  methods.add(Method(
    (m) => m
      ..name = "generate"
      ..body = Code("return 'CREATE TABLE ${element.name} ($fields) ;';")
      ..returns = Reference('String'),
  ));

  element.methods.forEach((query) {
    if (query.metadata != null && query.metadata.isNotEmpty) {
      ElementAnnotation meta = query.metadata[0];
      if (meta.constantValue.type.displayName == "Query") {
        meta.constantValue.getField("query").toStringValue();
      }
      if (meta.constantValue.type.displayName == "Insert") {
        var fields =
            element.fields.map((FieldElement field) => field.name).join(', ');
//          +
//          " " +
//          FieldsMapper().mapDartTypeToSql(field.type.displayName))
//          .join(', ');

        methods.add(Method((m) => m
          ..name = query.name
          ..returns = Reference("void")
          ..modifier = MethodModifier.async
          ..requiredParameters = ListBuilder(query.parameters)
          ..body = Code('''
            String path = await _getDatabasePath();

    Database database = await _getDatabase(path);
    
    await database.transaction((txn) async {
      int id1 = await txn.rawInsert('INSERT INTO ${element.name}($fields) VALUES(${element.fields.map((f) => '\${this.${f.name}}').join((','))})');
      
    });
    
          ''')));
//      "INSERT INTO ${element.name}($fields) VALUES ()";
      }
    }
  });

  return methods;
}

String _error(Object error) {
  final lines = '$error'.split('\n');
  final indented = lines.skip(1).map((l) => '//        $l'.trim()).join('\n');
  return '// Error: ${lines.first}\n$indented';
}
