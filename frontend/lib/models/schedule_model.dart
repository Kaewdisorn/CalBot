import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleModel {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;
  final int colorValue;
  final String? recurrenceRule;
  final List<DateTime>? exceptionDateList;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.isAllDay,
    this.colorValue = 0xFF42A5F5, // default blue
    this.recurrenceRule,
    this.exceptionDateList,
  });

  // Convert JSON from API to model
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      isAllDay: json['isAllDay'] ?? false,
      colorValue: json['colorValue'] ?? 0xFF42A5F5,
      recurrenceRule: json['recurrenceRule'],
      exceptionDateList: json['exceptionDateList'] != null
          ? (json['exceptionDateList'] as List).map<DateTime>((e) => DateTime.parse(e as String)).toList()
          : null,
    );
  }

  // Convert model to SfCalendar Appointment
  Appointment toCalendarAppointment() {
    return Appointment(
      id: id,
      subject: title,
      startTime: start,
      endTime: end,
      isAllDay: isAllDay,
      color: Color(colorValue),
      recurrenceRule: recurrenceRule,
      recurrenceExceptionDates: exceptionDateList,
    );
  }
}
