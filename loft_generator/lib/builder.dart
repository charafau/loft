import 'package:build/build.dart';
import 'package:loft_generator/loft_generator.dart';

import 'package:source_gen/source_gen.dart';

Builder loftFactory(BuilderOptions _) =>
    new SharedPartBuilder([new LoftGenerator()], 'loft');