import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/schedule_model.dart';

class HomeController extends GetxController {
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

  // observable schedule list — populated from JSON on init
  final RxList<ScheduleModel> scheduleList = <ScheduleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleSchedules();
  }

  void _loadSampleSchedules() {
    final jsonString = '''[
  {
    "id": "1",
    "title": "Team Meeting",
    "start": "2025-12-01T10:00:00.000Z",
    "end": "2025-12-01T11:00:00.000Z",
    "recurrenceRule": "FREQ=DAILY;INTERVAL=1;COUNT=10",
    "exceptionDateList": ["2025-12-05"],
    "colorValue": 4289835761
  },
  {
    "id": "2",
    "title": "Client Call",
    "start": "2025-12-02T15:00:00.000Z",
    "end": "2025-12-02T16:00:00.000Z",
    "location": "Seoul",
    "colorValue": 4287457102,
    "isAllDay" : true
  },
  {
    "id": "3",
    "title": "Shopping",
    "start": "2025-12-02T15:00:00.000Z",
    "end": "2025-12-03T16:00:00.000Z",
    "colorValue": 4287457102
  }
]''';

    try {
      final jsonArray = jsonDecode(jsonString) as List;
      final models = jsonArray.map((json) => ScheduleModel.fromJson(json)).toList();
      scheduleList.assignAll(models);
    } catch (e) {
      debugPrint('Error loading sample schedules: $e');
    }
  }
}
