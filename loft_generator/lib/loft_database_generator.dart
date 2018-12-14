import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

// import 'package:retrofit_generator/src/retrofit_source_class.dart';
import 'package:source_gen/source_gen.dart';
import 'package:loft/src/annotations.dart';

/**
 * THIS SCANS ALL FILES IN PROJECT AND CHECKS IF THIS IS YOUR RetrofitRestService
 * AND RUNS GENERATOR
 */
class LoftDatabaseGenerator extends GeneratorForAnnotation<LoftDb> {
  const LoftDatabaseGenerator();

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

  String _buildImplementionClass(
    ConstantReader annotation,
    ClassElement element,
  ) {
    final _dartfmt = new DartFormatter();

    final classBuilder = Class((c) => c
      ..name = '_\$${element.name}'
      ..extend = Reference(element.name)
      ..methods = ListBuilder(_buildCreateMethod(element, annotation)));
    ElementAnnotation metadata = element.metadata[0];

    List<DartObject> a = annotation.peek("entities").listValue;

    String asd = ' ';
    a.forEach((d) => asd += d.toTypeValue().toString());

    var b = TypeChecker.fromRuntime(a[0].runtimeType);

//  metadata.element.
//
//    var method = element.methods[0];
//

//    DartType returnType = method.returnType;
//    Element element2 = returnType.element;
//    element2.library.
//
    String classString = classBuilder.accept(DartEmitter()).toString();

    String output = _dartfmt.format(classString);



    return output;
//    return output;
  }

  List _buildCreateMethod(ClassElement element, ConstantReader annotation) {
    List<DartObject> daoClasses = annotation.peek("entities").listValue;

    String daoOutput = '''
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "demo.db");

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db
          .execute(${daoClasses.map((d) => d.toTypeValue().toString() + '().schema()').join(' + " "').toString()});

    });

    ''';

    daoOutput += ';';

    String dropCode = '''
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "demo.db");

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db
          .execute(${daoClasses.map((d) => d.toTypeValue().toString() + '().drop()').join(' + " "').toString()});

    });
    ''';

    return [
      Method(
        (m) => m
          ..name = "generate"
          ..modifier = MethodModifier.async
          ..body = Code(
            daoOutput,
          )
          ..returns = Reference('void'),
      ),
      Method(
            (m) => m
          ..name = "drop"
          ..modifier = MethodModifier.async
          ..body = Code(
            dropCode,
          )
          ..returns = Reference('void'),
      )
    ];
  }
}
