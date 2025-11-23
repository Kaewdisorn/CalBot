import 'package:flutter/material.dart';

String formatYMD(DateTime d) {
  return "${d.year.toString().padLeft(4, '0')}-"
      "${d.month.toString().padLeft(2, '0')}-"
      "${d.day.toString().padLeft(2, '0')}";
}

String formatTimeOfDayToHHMM(TimeOfDay time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return "$h:$m";
}

String formatTimeOfDayAMPM(TimeOfDay time) {
  final hour = time.hourOfPeriod.toString().padLeft(2, '0'); // 12-hour hour
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return "$hour:$minute $period";
}
