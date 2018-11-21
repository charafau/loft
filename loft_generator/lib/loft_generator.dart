import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
// import 'package:retrofit_generator/src/retrofit_source_class.dart';
import 'package:source_gen/source_gen.dart';
import 'package:loft/src/annotations.dart';

/**
 * THIS SCANS ALL FILES IN PROJECT AND CHECKS IF THIS IS YOUR RetrofitRestService
 * AND RUNS GENERATOR
 */
class LoftGenerator extends GeneratorForAnnotation<Entity> {
  const LoftGenerator();

  // @override
  // Future<String> generate(LibraryReader library, BuildStep buildStep) async {
  //   final result = new StringBuffer();

  //   for (final element in library.allElements) {
  //     //check if our current file contains RetrofitRestService
  //     if (element is ClassElement){
  //     // if (element is ClassElement &&
  //         // RetrofitSourceClass.needsBuiltValue(element)) {

  //       try {
  //         //generate code here
  //         // result.writeln(RetrofitSourceClass(element).generateCode());
  //       } catch (e, st) {
  //         result.writeln(_error(e));
  //         log.severe('Error in RetrofitGenerator for $element.', e, st);
  //       }
  //     }
  //   }

  //   if (result.isNotEmpty) {
  //     return '$result';
  //   } else {
  //     return null;
  //   }
  // }

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

  String a = element.fields.map((e) => e.name).join(', ');

  return a;
}

String _error(Object error) {
  final lines = '$error'.split('\n');
  final indented = lines.skip(1).map((l) => '//        $l'.trim()).join('\n');
  return '// Error: ${lines.first}\n$indented';
}
