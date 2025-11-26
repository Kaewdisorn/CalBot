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
      // Use grey if done, otherwise the provided color, default to blue if null
      color: isDone ? Colors.grey : (color ?? Colors.blue),
      id: id, // make sure to store id for easy lookup
    );
  }

  /// Allows creating a modified copy of Schedule
  Schedule copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    bool? isDone,
    Color? color,
    String? recurrenceRule,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      color: color ?? this.color,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    );
  }
}
