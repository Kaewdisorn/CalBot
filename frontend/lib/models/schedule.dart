import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Schedule {
  Schedule(this.eventName, this.location, this.startDate, this.startTime, this.to, this.background, this.isAllDay);

  String eventName;
  String location;
  DateTime startDate;
  TimeOfDay startTime;
  DateTime to;
  Color background;
  bool isAllDay;
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    final schedule = appointments![index];
    // Combine date + time
    return DateTime(schedule.startDate.year, schedule.startDate.month, schedule.startDate.day, schedule.startTime.hour, schedule.startTime.minute);
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String? getLocation(int index) {
    return appointments![index].location;
  }
}
