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
