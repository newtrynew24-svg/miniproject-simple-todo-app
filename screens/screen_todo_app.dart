import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:simple_todo_app/constants/app_colors.dart';
import 'package:simple_todo_app/widgets/day_task_group.dart';

class ScreenTodoApp extends StatefulWidget {
  const ScreenTodoApp({super.key});

  @override
  State<ScreenTodoApp> createState() => _ScreenTodoAppState();
}

class _ScreenTodoAppState extends State<ScreenTodoApp> {
  late List<DateTime> _weekDates;
  late DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    GoogleFonts.pendingFonts([GoogleFonts.poppins()]);
    _generateCurrentWeek();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only( top: 12,left: 16.0, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat('MMM').format(now)} ${now.year.toString()}',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Text(
                    "${_formatDate(_weekDates[0])} - ${_formatDate(_weekDates[6])}",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColorDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: DayTaskGroup()),
          ],
        ),
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: SafeArea(
  //       child: Padding(
  //         padding: const EdgeInsets.only(bottom: 64),
  //         child: DayTaskGroup(),
  //       ),
  //     ),
  //   );
  // }

  void _generateCurrentWeek() {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _weekDates = List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }
}
