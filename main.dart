import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:simple_todo_app/screens/screen_todo_app.dart';
import 'constants/app_colors.dart';
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('task_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
      ),
      home: ScreenTodoApp(),
    );
  }
}

