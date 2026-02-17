import 'package:hive_ce/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  int orderIndex;

  Task({
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? dueDate,
    this.orderIndex = 0,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.dueDate = dueDate ?? DateTime.now();
}


