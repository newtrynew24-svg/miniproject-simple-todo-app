import 'package:simple_todo_app/models/task.dart';

abstract class ListItem {}

class HeaderItem extends ListItem {
  final DateTime date;
  HeaderItem(this.date);
}

class TaskItem extends ListItem {
  final Task task;
  TaskItem(this.task);
}

class InputItem extends ListItem {
  final DateTime date;
  InputItem(this.date);
}

class DaySeparatorItem extends ListItem {
  final DateTime inputDate;
  final DateTime headerDate;

  DaySeparatorItem(this.inputDate, this.headerDate);
}