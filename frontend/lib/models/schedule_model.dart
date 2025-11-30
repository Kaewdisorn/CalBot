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
      isAllDay: _parseBool(json['isAllDay']),
      colorValue: json['colorValue'] ?? 0xFF42A5F5,
      recurrenceRule: json['recurrenceRule'],
      exceptionDateList: json['exceptionDateList'] != null
          ? (json['exceptionDateList'] as List).map<DateTime>((e) => DateTime.parse(e as String)).toList()
          : null,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'isAllDay': isAllDay,
      'colorValue': colorValue,
      if (recurrenceRule != null) 'recurrenceRule': recurrenceRule,
      if (exceptionDateList != null) 'exceptionDateList': exceptionDateList!.map((e) => e.toIso8601String()).toList(),
    };
  }

  // Convert model to SfCalendar Appointment
  Appointment toCalendarAppointment() {
    // For all-day events, set time to 12:00 AM - 11:59 PM
    final DateTime startTime = isAllDay ? DateTime(start.year, start.month, start.day, 0, 0, 0) : start;
    final DateTime endTime = isAllDay ? DateTime(end.year, end.month, end.day, 23, 59, 59) : end;

    return Appointment(
      id: id,
      subject: title,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      color: Color(colorValue),
      recurrenceRule: recurrenceRule,
      recurrenceExceptionDates: exceptionDateList,
    );
  }
}
