import 'package:analyzer/dart/element/element.dart';

class LoftSourceGen {

 final ClassElement element;

  LoftSourceGen(this.element);

  static bool needsBuiltValue(ClassElement element) {
    return (element.allSupertypes.any((type) => type.name == 'RetrofitRestService'));
  }

}