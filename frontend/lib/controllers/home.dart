import 'dart:ui';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/schedule.dart';

class HomeController {
  final allowedViews = <CalendarView>[CalendarView.day, CalendarView.week, CalendarView.month, CalendarView.schedule];

  /// Create a new Schedule object
  Schedule createSchedule(String title, String location, DateTime start, DateTime end, {Color color = const Color(0xFF0F8644), bool isAllDay = false}) {
    return Schedule(title, location, start, end, color, isAllDay);
  }
}
