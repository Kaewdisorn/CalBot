import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final calendarControllerProvider = Provider.autoDispose<CalendarController>((ref) {
  final controller = CalendarController();

  // Initial view setup
  controller.view = CalendarView.month;

  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
