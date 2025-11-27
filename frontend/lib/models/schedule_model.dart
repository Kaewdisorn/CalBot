import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleModel {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? recurrenceRule;
  final int colorValue;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.recurrenceRule,
    this.colorValue = 0xFF42A5F5, // default blue
  });

  // Convert JSON from API to model
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      recurrenceRule: json['recurrenceRule'],
      colorValue: json['colorValue'] ?? 0xFF42A5F5,
    );
  }

  // Convert model to SfCalendar Appointment
  Appointment toCalendarAppointment() {
    return Appointment(startTime: start, endTime: end, subject: title, color: Color(colorValue), recurrenceRule: recurrenceRule);
  }
}
