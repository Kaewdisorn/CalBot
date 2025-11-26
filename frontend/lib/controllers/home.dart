import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HomeController {
  final allowedViews = <CalendarView>[CalendarView.day, CalendarView.week, CalendarView.month, CalendarView.schedule];

  /// Create a new Appointment
  Appointment createAppointment({
    required String title,
    required String location,
    required DateTime startDate,
    required TimeOfDay startTime,
    required DateTime endDate,
    required TimeOfDay endTime,
    String description = '',
    Color color = const Color(0xFF0F8644),
    bool isAllDay = false,
    bool isDone = false,
    String recurrence = 'None', // <-- new field
  }) {
    return Appointment(
      startTime: DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute),
      endTime: DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute),
      subject: title,
      color: color,
      location: location,
      isAllDay: isAllDay,
      notes: jsonEncode({'description': description, 'isDone': isDone, 'recurrence': recurrence}), // ✅ JSON string
    );
  }
}
