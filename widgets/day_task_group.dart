import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:simple_todo_app/constants/app_colors.dart';
import 'package:simple_todo_app/repository/task_repository.dart';
import 'package:simple_todo_app/widgets/task_section.dart';

import '../models/list_item.dart';
import '../models/task.dart';
import 'day_header.dart';

class DayTaskGroup extends StatefulWidget {
  const DayTaskGroup({super.key});

  @override
  State<DayTaskGroup> createState() => _DayTaskGroupState();
}

class _DayTaskGroupState extends State<DayTaskGroup> {
  final TaskRepository _repository = TaskRepository();
  final Box<Task> _taskBox = Hive.box<Task>('task_box');

  List<ListItem> _items = [];
  late List<DateTime> _weekDates;
  bool _isInternalUpdate = false;

  @override
  void initState() {
    super.initState();
    _generateWeek();
    _refreshListFromHive();
    _taskBox.listenable().addListener(_onHiveChanged);
  }

  @override
  void dispose() {
    _taskBox.listenable().removeListener(_onHiveChanged);
    super.dispose();
  }


  void _generateWeek() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    _weekDates = List.generate(7, (i) => start.add(Duration(days: i)));
  }

  void _onHiveChanged() {
    if (_isInternalUpdate) return;
    _refreshListFromHive();
  }

  void _refreshListFromHive() {
    final List<ListItem> flatList = [];
    final allTasks = _taskBox.values.toList();

    for (int i = 0; i < _weekDates.length; i++) {
      final date = _weekDates[i];
      if (i == 0) flatList.add(HeaderItem(date));
      final tasksForDay = allTasks.where((t) => DateUtils.isSameDay(t.dueDate, date)).toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      flatList.addAll(tasksForDay.map((t) => TaskItem(t)));

      if (i < _weekDates.length - 1) {
        flatList.add(DaySeparatorItem(date, _weekDates[i + 1]));
      } else {
        flatList.add(InputItem(date));
      }
    }

    if (mounted) {
      setState(() => _items = flatList);
    }
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex--;
    if (newIndex < 0) newIndex = 0;

    if (newIndex == 0 && _items[0] is HeaderItem) newIndex = 1;

    setState(() {
      final item = _items.removeAt(oldIndex);
       _items.insert(newIndex, item);
    });

    final movedItem = _items[newIndex];
    if (movedItem is TaskItem) {
       _processTaskMove(movedItem.task, newIndex);
    }
  }

  void _processTaskMove(Task movedTask, int newIndex) {
    DateTime? targetDate;
    for (int i = newIndex; i >= 0; i--) {
      final item = _items[i];
      if (item is HeaderItem) {
        targetDate = item.date;
        break;
      }
      if (item is DaySeparatorItem) {
        targetDate = item.headerDate;
        break;
      }
    }

    if (targetDate == null) return;

    HapticFeedback.mediumImpact();
    _isInternalUpdate = true;

    final tasksToUpdate = <Task>[];

    if (!DateUtils.isSameDay(movedTask.dueDate, targetDate)) {
      movedTask.dueDate = targetDate;
      tasksToUpdate.add(movedTask);
    }

    int currentOrder = 0;
    bool counting = false;

    for (var item in _items) {
      if (item is HeaderItem && DateUtils.isSameDay(item.date, targetDate)) {
        counting = true;
        continue;
      }
      if (item is DaySeparatorItem) {
        if (DateUtils.isSameDay(item.headerDate, targetDate)) {
          counting = true;
          continue;
        } else if (counting) {
          break;
        }
      }
      if (item is InputItem && counting) break;

      if (counting && item is TaskItem) {
        if (item.task.orderIndex != currentOrder || item.task == movedTask) {
          item.task.orderIndex = currentOrder;
          if (!tasksToUpdate.contains(item.task)) {
            tasksToUpdate.add(item.task);
          }
        }
        currentOrder++;
      }
    }


    Future.wait(tasksToUpdate.map((t) => t.save())).then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      physics: const ClampingScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: _items.length,
      onReorderStart: (_) {
        HapticFeedback.lightImpact();
        _isInternalUpdate = true;
      },
      onReorder: _handleReorder,
      proxyDecorator: _buildProxyDecorator,
      itemBuilder: (context, index) {
        final item = _items[index];
        return switch (item) {
          HeaderItem() => _buildHeader(item, index),
          DaySeparatorItem() => _buildSeparator(item, index),
          InputItem() => _buildInput(item, index),
          TaskItem() => _buildTask(item, index),
          _ => const SizedBox.shrink(key: ValueKey('empty')),
        };
      },
    );
  }

  Widget _buildHeader(HeaderItem item, int index) {
    return ReorderableDelayedDragStartListener(
      key: ValueKey('header_${item.date.millisecondsSinceEpoch}'),
      index: index,
      enabled: false,
      child: DayHeader(date: item.date),
    );
  }

  Widget _buildSeparator(DaySeparatorItem item, int index) {
    return ReorderableDelayedDragStartListener(
      key: ValueKey('sep_${item.inputDate.day}_${item.headerDate.day}'),
      index: index,
      enabled: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 64),
            child: _buildNewTaskInput(item.inputDate, index, 'new_task_${item.inputDate}'),
          ),
          DayHeader(date: item.headerDate),
        ],
      ),
    );
  }

  Widget _buildInput(InputItem item, int index) {
    return ReorderableDelayedDragStartListener(
      key: ValueKey('input_${item.date.millisecondsSinceEpoch}'),
      index: index,
      enabled: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 64.0),
        child: _buildNewTaskInput(item.date, index, 'input_field_${item.date}'),
      ),
    );
  }

  Widget _buildTask(TaskItem item, int index) {
    final task = item.task;
    return ReorderableDelayedDragStartListener(
      key: ValueKey(task.key),
      index: index,
      child: TaskSection(
        id: task.key.toString(),
        index: index,
        initialText: task.title,
        isCompleted: task.isCompleted,
        onTextChanged: (val) {
          if (val.isEmpty) {
            _repository.deleteTask(task);
          } else {
            task.title = val;
            task.save();
          }
        },
        onToggleCompleted: () {
          setState(() => task.isCompleted = !task.isCompleted);
          task.save();
        },
      ),
    );
  }

  Widget _buildNewTaskInput(DateTime date, int index, String keyStr) {
    return TaskSection(
      key: ValueKey(keyStr),
      id: 'new',
      index: index,
      initialText: '',
      onTextChanged: (_) {},
      onSubmitted: (val) async {
        if (val.trim().isNotEmpty) {
          await _repository.addTask(val.trim(), date);
          _refreshListFromHive();
        }
      },
    );
  }

  Widget _buildProxyDecorator(Widget child, int index, Animation<double> animation) {
    final item = _items[index];
    Widget draggingChild = child;

    if (item is TaskItem) {
      draggingChild = TaskSection(
        id: item.task.key.toString(),
        index: index,
        initialText: item.task.title,
        isCompleted: item.task.isCompleted,
        isDragging: true,
        onTextChanged: (_) {},
      );
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final animValue = Curves.easeOutCubic.transform(animation.value);
        final scale = lerpDouble(1, 1.04, animValue)!;

        return Transform.scale(
          scale: scale,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground.withAlpha(240),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
                border: const Border.symmetric(
                  horizontal: BorderSide(color: Color(0xFFDDC584), width: 0.5),
                ),
              ),
              child: draggingChild,
            ),
          ),
        );
      },
    );
  }
}