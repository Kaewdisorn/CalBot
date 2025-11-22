import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';

class CalendarEvent {
  final String title;
  final DateTime start;
  final DateTime end;
  final Color color;

  CalendarEvent({required this.title, required this.start, required this.end, this.color = Colors.blue});

  // Convert to Syncfusion Appointment
  Appointment toAppointment() {
    return Appointment(startTime: start, endTime: end, subject: title, color: color);
  }
}
