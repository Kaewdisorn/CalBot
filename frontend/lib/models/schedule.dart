import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Schedule {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final bool isDone;
  final Color? color;
  final String? recurrenceRule; // iCalendar recurrence string, e.g., "FREQ=DAILY;COUNT=10"

  Schedule({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.description,
    this.isDone = false,
    this.color,
    this.recurrenceRule,
  });

  /// Convert to Syncfusion Appointment
  Appointment toAppointment() {
    return Appointment(
      startTime: startDate,
      endTime: endDate,
      subject: title,
      notes: description,
      isAllDay: false,
      recurrenceRule: recurrenceRule,
      color: color ?? (isDone ? Colors.grey : Colors.blue),
    );
  }
}
