import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Schedule {
  Schedule(this.eventName, this.location, this.startDate, this.startTime, this.endDate, this.endTime, this.background, this.isAllDay, this.description);

  String eventName;
  String location;
  DateTime startDate;
  TimeOfDay startTime;
  DateTime endDate;
  TimeOfDay endTime;
  Color background;
  bool isAllDay;
  String description;
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    final schedule = appointments![index] as Schedule;
    return DateTime(schedule.startDate.year, schedule.startDate.month, schedule.startDate.day, schedule.startTime.hour, schedule.startTime.minute);
  }

  @override
  DateTime getEndTime(int index) {
    final schedule = appointments![index] as Schedule;
    return DateTime(schedule.endDate.year, schedule.endDate.month, schedule.endDate.day, schedule.endTime.hour, schedule.endTime.minute);
  }

  @override
  String getSubject(int index) {
    return (appointments![index] as Schedule).eventName;
  }

  @override
  Color getColor(int index) {
    return (appointments![index] as Schedule).background;
  }

  @override
  bool isAllDay(int index) {
    return (appointments![index] as Schedule).isAllDay;
  }

  @override
  String? getLocation(int index) {
    return (appointments![index] as Schedule).location;
  }

  // NEW: Getter for description
  String? getDescription(int index) {
    return (appointments![index] as Schedule).description;
  }
}
