import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';

class DayHeader extends StatelessWidget {
  final DateTime date;

  const DayHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final String dayName = DateFormat('EEE', 'en_US').format(date);
    final String dateStr = DateFormat('MMM d', 'en_US').format(date);

    final now = DateTime.now();
    final bool isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (isToday)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 100,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFFFDB79),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        Padding(
          padding: isToday
              ? EdgeInsets.symmetric(horizontal: 24, vertical: 8)
              : EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      dayName,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.weekdayTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.primaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
