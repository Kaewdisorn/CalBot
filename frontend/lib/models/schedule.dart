import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Schedule {
  Schedule(
    this.eventName,
    this.location,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.background,
    this.isAllDay,
    this.description,
    this.isDone,
  );

  String eventName;
  String location;
  DateTime startDate;
  TimeOfDay startTime;
  DateTime endDate;
  TimeOfDay endTime;
  Color background;
  bool isAllDay;
  String description;
  bool isDone;
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    final s = appointments![index];
    return DateTime(s.startDate.year, s.startDate.month, s.startDate.day, s.startTime.hour, s.startTime.minute);
  }

  @override
  DateTime getEndTime(int index) {
    final s = appointments![index];
    return DateTime(s.endDate.year, s.endDate.month, s.endDate.day, s.endTime.hour, s.endTime.minute);
  }

  @override
  String getSubject(int index) {
    final s = appointments![index];
    return s.isDone ? s.eventName : s.eventName;
  }

  @override
  String? getNotes(int index) {
    return appointments![index].description;
  }

  @override
  String? getLocation(int index) {
    return appointments![index].location;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
