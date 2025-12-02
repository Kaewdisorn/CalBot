import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/schedule_model.dart';

class HomeController extends GetxController {
  final List<CalendarView> allowedViews = <CalendarView>[CalendarView.month, CalendarView.schedule];

  // observable schedule list — populated from JSON on init
  final RxList<ScheduleModel> scheduleList = <ScheduleModel>[].obs;
  final RxBool isAgendaView = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleSchedules();
  }

  void _loadSampleSchedules() {
    final sampleData = [
      {
        "id": "1",
        "title": "Team Meeting",
        "start": "2025-12-03T10:00:00.000Z",
        "end": "2025-12-03T11:00:00.000Z",
        "recurrenceRule": "FREQ=DAILY;INTERVAL=1;COUNT=10",
        "exceptionDateList": ["2025-12-07"],
        "colorValue": 4282557941, // Blue - 0xFF42A5F5
        "doneOccurrences": ["2025-12-03", "2025-12-04"],
      },
      {
        "id": "2",
        "title": "Weekly Review",
        "start": "2025-12-03T14:00:00.000Z",
        "end": "2025-12-03T15:00:00.000Z",
        "recurrenceRule": "FREQ=WEEKLY;BYDAY=MO,WE,FR;COUNT=6",
        "location": "Conference Room A",
        "colorValue": 4284947020, // Green - 0xFF66BB6A
      },
      {
        "id": "3",
        "title": "Project Deadline",
        "start": "2025-12-05T09:00:00.000Z",
        "end": "2025-12-05T17:00:00.000Z",
        "isAllDay": true,
        "colorValue": 4293467984, // Red - 0xFFEF5350
        "note": "Submit final report",
        "isDone": false,
      },
      {
        "id": "4",
        "title": "Monthly Report",
        "start": "2025-12-15T10:00:00.000Z",
        "end": "2025-12-15T11:30:00.000Z",
        "recurrenceRule": "FREQ=MONTHLY;BYMONTHDAY=15;COUNT=6",
        "colorValue": 4289420220, // Purple - 0xFFAB47BC
        "location": "Head Office",
      },
      {
        "id": "5",
        "title": "Gym Session",
        "start": "2025-12-03T18:00:00.000Z",
        "end": "2025-12-03T19:30:00.000Z",
        "recurrenceRule": "FREQ=WEEKLY;BYDAY=TU,TH;COUNT=8",
        "colorValue": 4294938179, // Orange - 0xFFFF7043
        "isDone": false,
      },
    ];

    final jsonString = jsonEncode(sampleData);

    try {
      final jsonData = jsonDecode(jsonString) as List;
      final models = jsonData.map((json) => ScheduleModel.fromJson(json)).toList();
      scheduleList.assignAll(models);
    } catch (e) {
      debugPrint('Error loading sample schedules: $e');
    }
  }
}
