import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Helper to create Appointment from your previous Schedule data
Appointment createAppointment({
  required String eventName,
  required String location,
  required DateTime startDate,
  required TimeOfDay startTime,
  required DateTime endDate,
  required TimeOfDay endTime,
  required Color background,
  required bool isAllDay,
  required String description,
  required bool isDone,
}) {
  return Appointment(
    startTime: DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute),
    endTime: DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute),
    subject: eventName,
    color: background,
    location: location,
    isAllDay: isAllDay,
    notes: jsonEncode({'description': description, 'isDone': isDone}),
  );
}

/// Custom CalendarDataSource using Appointment
class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Appointment> source) {
    appointments = source;
  }

  /// Get description from notes
  String? getDescription(int index) {
    final appt = appointments![index];
    if (appt.notes != null) {
      final data = jsonDecode(appt.notes!);
      return data['description'] ?? '';
    }
    return '';
  }

  /// Check if appointment is done
  bool isDone(int index) {
    final appt = appointments![index];
    if (appt.notes != null) {
      final data = jsonDecode(appt.notes!);
      return data['isDone'] ?? false;
    }
    return false;
  }

  /// Toggle done status
  void toggleDone(int index) {
    final appt = appointments![index];
    Map<String, dynamic> data = {};
    if (appt.notes != null) {
      data = jsonDecode(appt.notes!);
    }
    data['isDone'] = !(data['isDone'] ?? false);
    appt.notes = jsonEncode(data);
    notifyListeners(CalendarDataSourceAction.reset, appointments!);
  }
}
