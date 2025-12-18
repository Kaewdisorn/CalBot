import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'note_data_model.dart';

class ScheduleModel {
  final String gid; // user id
  final String uid; // schedule unique id
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
  final List<DateTime> doneOccurrences; // For recurring events

  /// Check if this is a recurring event
  bool get isRecurring => recurrenceRule != null && recurrenceRule!.isNotEmpty;

  ScheduleModel({
    required this.gid,
    required this.uid,
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
    this.doneOccurrences = const [],
  });

  // Convert JSON from API to model
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    // 1. Parse note field - it may contain extended data as JSON
    final dynamic noteRaw = json['note'];
    String? noteJsonString;
    NoteDataModel noteData = const NoteDataModel();

    if (noteRaw is Map<String, dynamic>) {
      // If it's already a Map, encode it to JSON string
      noteJsonString = jsonEncode(noteRaw);
      noteData = NoteDataModel.fromJsonString(noteJsonString);
    } else if (noteRaw is String) {
      noteJsonString = noteRaw;
      noteData = NoteDataModel.fromJsonString(noteRaw);
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
      gid: json['gid'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
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
      doneOccurrences: noteData.doneOccurrences, // Preserve done occurrences
    );
  }

  // Convert model to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'gid': gid,
      'uid': uid,
      'title': title,
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
      'location': location,
      'isAllDay': isAllDay,
      'note': note,
      'colorValue': colorValue,
      'isDone': isDone,
      if (recurrenceRule != null) 'recurrenceRule': recurrenceRule,
      if (exceptionDateList != null && exceptionDateList!.isNotEmpty) 'exceptionDateList': exceptionDateList!.map((e) => e.toIso8601String()).toList(),
      if (doneOccurrences.isNotEmpty) 'doneOccurrences': doneOccurrences.map((e) => e.toIso8601String()).toList(),
    };
  }

  // Convert model to SfCalendar Appointment
  Appointment toCalendarAppointment() {
    // For all-day events, set time to 12:00 AM - 11:59 PM
    final DateTime startTime = isAllDay ? DateTime(start.year, start.month, start.day, 0, 0, 0) : start;
    final DateTime endTime = isAllDay ? DateTime(end.year, end.month, end.day, 23, 59, 59) : end;

    // Store extended data (isDone, description, doneOccurrences) as JSON in notes field
    final noteData = NoteDataModel(isDone: isDone, description: note, doneOccurrences: doneOccurrences);
    final String? notesJson = noteData.isEmpty ? null : noteData.toJsonString();

    // For non-recurring events, use gray if done
    // For recurring events, keep original color (individual occurrences will be handled in appointmentBuilder)
    final Color displayColor = (!isRecurring && isDone) ? Colors.grey : Color(colorValue);

    return Appointment(
      id: uid, // schedule unique id
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
  NoteDataModel get noteData => NoteDataModel(isDone: isDone, description: note, doneOccurrences: doneOccurrences);

  /// Check if a specific occurrence is done (for recurring events)
  bool isOccurrenceDone(DateTime occurrenceDate) {
    if (!isRecurring) return isDone;
    final normalizedDate = DateTime(occurrenceDate.year, occurrenceDate.month, occurrenceDate.day);
    return doneOccurrences.any((d) {
      final normalizedDone = DateTime(d.year, d.month, d.day);
      return normalizedDone.isAtSameMomentAs(normalizedDate);
    });
  }

  /// Create a copy with occurrence done status updated
  ScheduleModel copyWithOccurrenceDone(DateTime occurrenceDate, bool done) {
    if (!isRecurring) {
      // Non-recurring: just update isDone
      return ScheduleModel(
        gid: gid,
        uid: uid,
        title: title,
        start: start,
        end: end,
        isAllDay: isAllDay,
        note: note,
        location: location,
        colorValue: colorValue,
        recurrenceRule: recurrenceRule,
        exceptionDateList: exceptionDateList,
        isDone: done,
        doneOccurrences: doneOccurrences,
      );
    }

    // Recurring: update doneOccurrences list
    final normalizedDate = DateTime(occurrenceDate.year, occurrenceDate.month, occurrenceDate.day);
    List<DateTime> newDoneOccurrences;

    if (done) {
      // Add to list if not already present
      if (!isOccurrenceDone(occurrenceDate)) {
        newDoneOccurrences = [...doneOccurrences, normalizedDate];
      } else {
        newDoneOccurrences = doneOccurrences;
      }
    } else {
      // Remove from list
      newDoneOccurrences = doneOccurrences.where((d) {
        final normalizedDone = DateTime(d.year, d.month, d.day);
        return !normalizedDone.isAtSameMomentAs(normalizedDate);
      }).toList();
    }

    return ScheduleModel(
      gid: gid,
      uid: uid,
      title: title,
      start: start,
      end: end,
      isAllDay: isAllDay,
      note: note,
      location: location,
      colorValue: colorValue,
      recurrenceRule: recurrenceRule,
      exceptionDateList: exceptionDateList,
      isDone: isDone,
      doneOccurrences: newDoneOccurrences,
    );
  }

  /// Helper to parse NoteData from an Appointment's notes field
  static NoteDataModel parseNoteData(String? notes) => NoteDataModel.fromJsonString(notes);
}
