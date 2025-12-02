import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Extended note data stored as JSON in Appointment.notes field
/// This allows storing additional fields that Appointment doesn't support
class NoteData {
  final bool isDone;
  final String? description;

  // Add more fields as needed in the future
  // final String? category;
  // final int? priority;

  const NoteData({this.isDone = false, this.description});

  /// Parse NoteData from JSON string (stored in Appointment.notes)
  factory NoteData.fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return const NoteData();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return NoteData(isDone: json['isDone'] as bool? ?? false, description: json['description'] as String?);
    } catch (e) {
      // If parsing fails, treat the whole string as description (backward compatibility)
      return NoteData(description: jsonString);
    }
  }

  /// Convert to JSON string for storing in Appointment.notes
  String toJsonString() {
    return jsonEncode({'isDone': isDone, if (description != null && description!.isNotEmpty) 'description': description});
  }

  /// Check if there's any meaningful data
  bool get isEmpty => !isDone && (description == null || description!.isEmpty);
}

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
    // 1. Parse note field - it may contain extended data as JSON
    final dynamic noteRaw = json['note'];
    String? noteJsonString;
    NoteData noteData = const NoteData();

    if (noteRaw is Map<String, dynamic>) {
      // If it's already a Map, encode it to JSON string
      noteJsonString = jsonEncode(noteRaw);
      noteData = NoteData.fromJsonString(noteJsonString);
    } else if (noteRaw is String) {
      noteJsonString = noteRaw;
      noteData = NoteData.fromJsonString(noteRaw);
    }

    // 2. Extract and convert exception dates
    List<DateTime>? exceptionDates;
    if (json['exceptionDateList'] is List) {
      exceptionDates = (json['exceptionDateList'] as List<dynamic>).map((e) => DateTime.parse(e.toString())).toList();
    }

    // 3. Determine isDone - check both direct field and note data
    final bool isDoneValue = json['isDone'] as bool? ?? noteData.isDone;

    // 4. Construct the Model
    return ScheduleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      start: DateTime.parse(json['start'] as String).toLocal(),
      end: DateTime.parse(json['end'] as String).toLocal(),
      location: json['location'] as String? ?? '',
      isAllDay: json['isAllDay'] as bool? ?? false,
      note: noteData.description, // Extract description from note data
      colorValue: json['colorValue'] as int? ?? 0xFF42A5F5,
      recurrenceRule: json['recurrenceRule'] as String?,
      exceptionDateList: exceptionDates,
      isDone: isDoneValue,
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

    // Store extended data (isDone, description) as JSON in notes field
    final noteData = NoteData(isDone: isDone, description: note);
    final String? notesJson = noteData.isEmpty ? null : noteData.toJsonString();

    // If done, show as gray color
    final Color displayColor = isDone ? Colors.grey : Color(colorValue);

    return Appointment(
      id: id,
      subject: title,
      startTime: startTime,
      endTime: endTime,
      location: location,
      isAllDay: isAllDay,
      notes: notesJson, // Store extended data as JSON
      color: displayColor,
      recurrenceRule: recurrenceRule,
      recurrenceExceptionDates: exceptionDateList,
    );
  }

  /// Get NoteData from this schedule
  NoteData get noteData => NoteData(isDone: isDone, description: note);

  /// Helper to parse NoteData from an Appointment's notes field
  static NoteData parseNoteData(String? notes) => NoteData.fromJsonString(notes);
}
