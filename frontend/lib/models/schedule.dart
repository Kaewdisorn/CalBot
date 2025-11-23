import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Schedule {
  Schedule(this.eventName, this.location, this.startDate, this.to, this.background, this.isAllDay);

  String eventName;
  String location;
  DateTime startDate;
  DateTime to;
  Color background;
  bool isAllDay;
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Schedule> source) {
    appointments = source;
  }

  @override
  String getLocation(int index) => appointments![index].location;

  @override
  DateTime getStartDate(int index) => appointments![index].startDate;

  @override
  DateTime getEndTime(int index) => appointments![index].to;

  @override
  String getSubject(int index) => appointments![index].eventName;

  @override
  Color getColor(int index) => appointments![index].background;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;
}
