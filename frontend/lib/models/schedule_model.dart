import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleModel {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? location;
  final bool isAllDay;
  final String? note;
  final int colorValue;
  final String? recurrenceRule;
  final List<DateTime>? exceptionDateList;
  final bool isDone;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.isAllDay,
    this.note,
    this.location,
    this.colorValue = 0xFF42A5F5, // default blue
    this.recurrenceRule,
    this.exceptionDateList,
    this.isDone = false,
  });

  // Convert JSON from API to model
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    // 1. Initialize _note to null first, so the compiler is satisfied.
    // We use 'dynamic' to check the type safely before casting/encoding.
    final dynamic noteRaw = json['note'];
    String? parsedNote;

    if (noteRaw is Map<String, dynamic>) {
      // If it's a Map (e.g., {"isDone": true}), encode it to a String.
      parsedNote = jsonEncode(noteRaw);
    } else if (noteRaw is String) {
      // If it's already a String, use it directly.
      parsedNote = noteRaw;
    }
    // Otherwise, parsedNote remains null.

    // 2. Extract and convert exception dates
    List<DateTime>? exceptionDates;
    if (json['exceptionDateList'] is List) {
      // Ensure the list items are iterated and parsed safely
      exceptionDates = (json['exceptionDateList'] as List<dynamic>).map((e) => DateTime.parse(e.toString())).toList();
    }

    // 3. Construct the Model, ensuring required fields are handled robustly.
    return ScheduleModel(
      // Use `as String? ?? ''` for required Strings to ensure type safety
      // and provide a default empty string if the key is missing or null.
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',

      // Date parsing: Safely check for the key/value before parsing.
      start: DateTime.parse(json['start'] as String).toLocal(), // Assuming 'start' is always present and a String
      end: DateTime.parse(json['end'] as String).toLocal(), // Assuming 'end' is always present and a String
      // Location: Use safe casting and provide a default empty string.
      location: json['location'] as String? ?? '',

      // isAllDay: Use explicit null check and default to false.
      isAllDay: json['isAllDay'] as bool? ?? false,

      // Note: Use the parsed String
      note: parsedNote,

      // Color: Use null-coalescing with the default int value.
      colorValue: json['colorValue'] as int? ?? 0xFF42A5F5,

      // Recurrence: Simple casting.
      recurrenceRule: json['recurrenceRule'] as String?,

      // Exception Dates: Use the safely parsed list.
      exceptionDateList: exceptionDates,

      // isDone: Use explicit null check and default to false.
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  // Convert model to JSON
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'start': start.toIso8601String(),
  //     'end': end.toIso8601String(),
  //     'location': location,
  //     'isAllDay': isAllDay,
  //     'note': note,
  //     'colorValue': colorValue,
  //     if (recurrenceRule != null) 'recurrenceRule': recurrenceRule,
  //     if (exceptionDateList != null) 'exceptionDateList': exceptionDateList!.map((e) => e.toIso8601String()).toList(),
  //   };
  // }

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
      location: location,
      isAllDay: isAllDay,
      notes: note,
      color: Color(colorValue),
      recurrenceRule: recurrenceRule,
      recurrenceExceptionDates: exceptionDateList,
    );
  }
}
