import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/schedule_model.dart';

class HomeController {
  final List<CalendarView> allowedViews = <CalendarView>[
    CalendarView.day,
    CalendarView.week,
    // CalendarView.workWeek,
    CalendarView.timelineDay,
    CalendarView.timelineWeek,
    // CalendarView.timelineWorkWeek,
    CalendarView.month,
    CalendarView.schedule,
  ];

  // observable schedule list retained across rebuilds
  final RxList<ScheduleModel> scheduleList = <ScheduleModel>[
    ScheduleModel.fromJson({
      'id': '1',
      'title': 'Team Meeting',
      'start': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
      'end': DateTime.now().add(Duration(hours: 2)).toIso8601String(),
      'recurrenceRule': 'FREQ=DAILY;INTERVAL=1;COUNT=10',
      'exceptionDateList': [DateTime(2025, 12, 05).toIso8601String()],
      'colorValue': 0xFF42A5F5,
    }),
    ScheduleModel.fromJson({
      'id': '2',
      'title': 'Client Call',
      'start': DateTime.now().add(Duration(days: 1, hours: 3)).toIso8601String(),
      'end': DateTime.now().add(Duration(days: 1, hours: 4)).toIso8601String(),
      'colorValue': 0xFF66BB6A,
    }),
    ScheduleModel.fromJson({
      'id': '3',
      'title': 'Shopping',
      'start': DateTime.now().add(Duration(days: 1, hours: 3)).toIso8601String(),
      'end': DateTime.now().add(Duration(days: 2, hours: 4)).toIso8601String(),
      'colorValue': 0xFF66BB6A,
    }),
  ].obs;
}
