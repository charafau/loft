import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:loft/src/annotations.dart';
import 'package:loft_generator/fields_mapper.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

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
      .map(
        (FieldElement field) =>
            ReCase(field.name).snakeCase +
            " " +
            FieldsMapper().mapDartTypeToSql(field.type.displayName) +
            _isPrimaryKey(field),
      )
      .join(', ');

  List<Method> methods = [];

  methods.add(Method(
    (m) => m
      ..name = "generate"
      ..body = Code("return 'CREATE TABLE ${element.name} ($fields) ;';")
      ..returns = Reference('String'),
  ));

  methods.add(Method(
    (m) => m
      ..name = "drop"
      ..body =
          Code("return 'DROP TABLE IF EXISTS ${element.name};';")
      ..returns = Reference('String'),
  ));

  return methods;
}

String _isPrimaryKey(FieldElement f) {
  if (f.metadata != null && f.metadata.length > 0) {
    var meta = f.metadata[0];
    print('meta $meta');
    var annotation = meta.constantValue.type.name;
    if (annotation == "PrimaryKey") {
      return " NOT NULL PRIMARY KEY AUTOINCREMENT";
    }
  }
  return "";
}

String _error(Object error) {
  final lines = '$error'.split('\n');
  final indented = lines.skip(1).map((l) => '//        $l'.trim()).join('\n');
  return '// Error: ${lines.first}\n$indented';
}
