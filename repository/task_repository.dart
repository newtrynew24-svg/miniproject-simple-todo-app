import 'package:hive_ce/hive.dart';

import '../models/task.dart';

class TaskRepository {

  final Box<Task> _box = Hive.box<Task>('task_box');

  List<Task> getAllTasks() {
    return _box.values.toList();
  }

  Future<void> addTask(String title, DateTime date) async {
    final task = Task(title: title, dueDate: date);
    await _box.add(task);
  }

  Future<void> updateTask(Task task) async {
    await task.save();
  }

  Future<void> deleteTask(Task task) async {
    await task.delete();
  }

  Future<void> updateAllTasks(List<Task> tasks) async {
    await _box.clear();
    await _box.addAll(tasks);
  }
}

