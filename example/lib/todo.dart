import 'package:loft/src/annotations.dart';

@Entity("todos")
class Todo {
  final String name;
  final bool isDone;

  Todo(this.name, this.isDone);
}
