import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/schedule_model.dart';

/// Recurrence frequency options
enum RecurrenceFrequency { never, daily, weekly, monthly }

/// Recurrence end type
enum RecurrenceEndType { never, until, count }

/// Days of week for weekly recurrence
enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class ScheduleFormController extends GetxController {
  // Text controllers
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController noteController;

  // Reactive state
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<TimeOfDay> startTime = TimeOfDay.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  final Rx<TimeOfDay> endTime = TimeOfDay.now().obs;
  final RxBool isAllDay = false.obs;
  final Rx<Color> selectedColor = const Color(0xFF42A5F5).obs;
  final RxBool isDone = false.obs;

  // Recurrence state
  final Rx<RecurrenceFrequency> recurrenceFrequency = RecurrenceFrequency.never.obs;
  final RxInt recurrenceInterval = 1.obs; // Every X days/weeks/months
  final RxList<WeekDay> selectedWeekDays = <WeekDay>[].obs; // For weekly recurrence
  final Rx<RecurrenceEndType> recurrenceEndType = RecurrenceEndType.never.obs;
  final RxInt recurrenceCount = 10.obs; // Number of occurrences
  final Rx<DateTime?> recurrenceEndDate = Rx<DateTime?>(null); // End by date
  final RxInt monthlyDay = 1.obs; // Day of month for monthly recurrence

  // Edit mode tracking
  ScheduleModel? existingSchedule;
  bool get isEditMode => existingSchedule != null;

  // For recurring events - track which occurrence was tapped
  DateTime? tappedOccurrenceDate;

  // Color palette for schedule
  static const List<Color> colorPalette = [
    Color(0xFF42A5F5), // Blue
    Color(0xFF66BB6A), // Green
    Color(0xFFEF5350), // Red
    Color(0xFFAB47BC), // Purple
    Color(0xFFFF7043), // Orange
    Color(0xFF26A69A), // Teal
    Color(0xFFEC407A), // Pink
    Color(0xFF5C6BC0), // Indigo
  ];

  /// Initialize the controller with optional existing schedule or initial date
  void initialize({ScheduleModel? schedule, DateTime? initialDate, DateTime? tappedOccurrenceDate}) {
    existingSchedule = schedule;
    this.tappedOccurrenceDate = tappedOccurrenceDate;
    final now = initialDate ?? DateTime.now();

    titleController = TextEditingController(text: schedule?.title ?? '');
    locationController = TextEditingController(text: schedule?.location ?? '');
    noteController = TextEditingController(text: schedule?.note ?? '');

    startDate.value = schedule?.start ?? now;
    startTime.value = TimeOfDay.fromDateTime(schedule?.start ?? now);
    endDate.value = schedule?.end ?? now.add(const Duration(hours: 1));
    endTime.value = TimeOfDay.fromDateTime(schedule?.end ?? now.add(const Duration(hours: 1)));
    isAllDay.value = schedule?.isAllDay ?? false;
    selectedColor.value = schedule != null ? Color(schedule.colorValue) : colorPalette[0];
    monthlyDay.value = startDate.value.day;

    // Parse existing recurrence rule
    if (schedule?.recurrenceRule != null && schedule!.recurrenceRule!.isNotEmpty) {
      _parseRecurrenceRule(schedule.recurrenceRule!);
    } else {
      // Reset recurrence state
      recurrenceFrequency.value = RecurrenceFrequency.never;
      recurrenceInterval.value = 1;
      selectedWeekDays.clear();
      recurrenceCount.value = 10;
      recurrenceEndDate.value = null;
      recurrenceEndType.value = RecurrenceEndType.never;
    }

    // For recurring events, check if this specific occurrence is done
    if (schedule != null && schedule.isRecurring && tappedOccurrenceDate != null) {
      isDone.value = schedule.isOccurrenceDone(tappedOccurrenceDate);
    } else {
      isDone.value = schedule?.isDone ?? false;
    }
  }

  /// Parse an existing recurrence rule (RFC 5545 format)
  void _parseRecurrenceRule(String rule) {
    final parts = rule.split(';');
    final Map<String, String> ruleMap = {};
    for (final part in parts) {
      final kv = part.split('=');
      if (kv.length == 2) {
        ruleMap[kv[0]] = kv[1];
      }
    }

    // Parse frequency
    final freq = ruleMap['FREQ'];
    switch (freq) {
      case 'DAILY':
        recurrenceFrequency.value = RecurrenceFrequency.daily;
        break;
      case 'WEEKLY':
        recurrenceFrequency.value = RecurrenceFrequency.weekly;
        break;
      case 'MONTHLY':
        recurrenceFrequency.value = RecurrenceFrequency.monthly;
        break;
      default:
        recurrenceFrequency.value = RecurrenceFrequency.never;
    }

    // Parse interval
    recurrenceInterval.value = int.tryParse(ruleMap['INTERVAL'] ?? '1') ?? 1;

    // Parse count
    if (ruleMap.containsKey('COUNT')) {
      recurrenceCount.value = int.tryParse(ruleMap['COUNT']!) ?? 10;
      recurrenceEndType.value = RecurrenceEndType.count;
    }

    // Parse until date
    if (ruleMap.containsKey('UNTIL')) {
      try {
        final untilStr = ruleMap['UNTIL']!;
        if (untilStr.length >= 8) {
          final year = int.parse(untilStr.substring(0, 4));
          final month = int.parse(untilStr.substring(4, 6));
          final day = int.parse(untilStr.substring(6, 8));
          recurrenceEndDate.value = DateTime(year, month, day);
          recurrenceEndType.value = RecurrenceEndType.until;
        }
      } catch (_) {}
    }

    // If no end condition, set to never
    if (!ruleMap.containsKey('COUNT') && !ruleMap.containsKey('UNTIL')) {
      recurrenceEndType.value = RecurrenceEndType.never;
    }

    // Parse BYDAY for weekly recurrence
    if (ruleMap.containsKey('BYDAY')) {
      selectedWeekDays.clear();
      final days = ruleMap['BYDAY']!.split(',');
      for (final day in days) {
        final dayCode = day.replaceAll(RegExp(r'[0-9-]'), '');
        switch (dayCode) {
          case 'MO':
            selectedWeekDays.add(WeekDay.monday);
            break;
          case 'TU':
            selectedWeekDays.add(WeekDay.tuesday);
            break;
          case 'WE':
            selectedWeekDays.add(WeekDay.wednesday);
            break;
          case 'TH':
            selectedWeekDays.add(WeekDay.thursday);
            break;
          case 'FR':
            selectedWeekDays.add(WeekDay.friday);
            break;
          case 'SA':
            selectedWeekDays.add(WeekDay.saturday);
            break;
          case 'SU':
            selectedWeekDays.add(WeekDay.sunday);
            break;
        }
      }
    }

    // Parse BYMONTHDAY for monthly recurrence
    if (ruleMap.containsKey('BYMONTHDAY')) {
      monthlyDay.value = int.tryParse(ruleMap['BYMONTHDAY']!) ?? startDate.value.day;
    }
  }

  /// Build recurrence rule string (RFC 5545 format)
  String? buildRecurrenceRule() {
    if (recurrenceFrequency.value == RecurrenceFrequency.never) {
      return null;
    }

    final List<String> parts = [];

    // Frequency
    switch (recurrenceFrequency.value) {
      case RecurrenceFrequency.daily:
        parts.add('FREQ=DAILY');
        break;
      case RecurrenceFrequency.weekly:
        parts.add('FREQ=WEEKLY');
        break;
      case RecurrenceFrequency.monthly:
        parts.add('FREQ=MONTHLY');
        break;
      default:
        return null;
    }

    // Interval
    if (recurrenceInterval.value > 1) {
      parts.add('INTERVAL=${recurrenceInterval.value}');
    }

    // BYDAY for weekly recurrence
    if (recurrenceFrequency.value == RecurrenceFrequency.weekly && selectedWeekDays.isNotEmpty) {
      final dayStrings = selectedWeekDays.map((d) {
        switch (d) {
          case WeekDay.monday:
            return 'MO';
          case WeekDay.tuesday:
            return 'TU';
          case WeekDay.wednesday:
            return 'WE';
          case WeekDay.thursday:
            return 'TH';
          case WeekDay.friday:
            return 'FR';
          case WeekDay.saturday:
            return 'SA';
          case WeekDay.sunday:
            return 'SU';
        }
      }).toList();
      parts.add('BYDAY=${dayStrings.join(",")}');
    }

    // BYMONTHDAY for monthly recurrence
    if (recurrenceFrequency.value == RecurrenceFrequency.monthly) {
      parts.add('BYMONTHDAY=${monthlyDay.value}');
    }

    // End condition
    switch (recurrenceEndType.value) {
      case RecurrenceEndType.until:
        if (recurrenceEndDate.value != null) {
          final d = recurrenceEndDate.value!;
          final untilStr = '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T235959Z';
          parts.add('UNTIL=$untilStr');
        }
        break;
      case RecurrenceEndType.count:
        parts.add('COUNT=${recurrenceCount.value}');
        break;
      case RecurrenceEndType.never:
        // No end condition - repeats forever
        break;
    }

    return parts.join(';');
  }

  @override
  void onClose() {
    titleController.dispose();
    locationController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void setStartDate(DateTime date) {
    startDate.value = date;
    monthlyDay.value = date.day; // Update monthly day when start date changes
    if (endDate.value.isBefore(startDate.value)) {
      endDate.value = startDate.value;
    }
  }

  void setEndDate(DateTime date) {
    endDate.value = date;
  }

  void setStartTime(TimeOfDay time) {
    startTime.value = time;
  }

  void setEndTime(TimeOfDay time) {
    endTime.value = time;
  }

  void toggleAllDay(bool value) {
    isAllDay.value = value;
  }

  void setColor(Color color) {
    selectedColor.value = color;
  }

  void toggleIsDone(bool value) {
    isDone.value = value;
  }

  void setRecurrenceFrequency(RecurrenceFrequency freq) {
    recurrenceFrequency.value = freq;
    // Set default weekday when switching to weekly
    if (freq == RecurrenceFrequency.weekly && selectedWeekDays.isEmpty) {
      final weekday = WeekDay.values[startDate.value.weekday - 1];
      selectedWeekDays.add(weekday);
    }
    // Set default monthly day
    if (freq == RecurrenceFrequency.monthly) {
      monthlyDay.value = startDate.value.day;
    }
  }

  void toggleWeekDay(WeekDay day) {
    if (selectedWeekDays.contains(day)) {
      if (selectedWeekDays.length > 1) {
        selectedWeekDays.remove(day);
      }
    } else {
      selectedWeekDays.add(day);
    }
  }

  void setRecurrenceInterval(int interval) {
    recurrenceInterval.value = interval.clamp(1, 99);
  }

  void setRecurrenceCount(int count) {
    recurrenceCount.value = count.clamp(1, 999);
  }

  void setRecurrenceEndDate(DateTime? date) {
    recurrenceEndDate.value = date;
  }

  void setRecurrenceEndType(RecurrenceEndType type) {
    recurrenceEndType.value = type;
  }

  void setMonthlyDay(int day) {
    monthlyDay.value = day.clamp(1, 31);
  }

  /// Validate and build the schedule model
  ScheduleModel? buildSchedule() {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return null;
    }

    final startDateTime = DateTime(
      startDate.value.year,
      startDate.value.month,
      startDate.value.day,
      isAllDay.value ? 0 : startTime.value.hour,
      isAllDay.value ? 0 : startTime.value.minute,
    );

    final endDateTime = DateTime(
      endDate.value.year,
      endDate.value.month,
      endDate.value.day,
      isAllDay.value ? 23 : endTime.value.hour,
      isAllDay.value ? 59 : endTime.value.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      Get.snackbar(
        'Error',
        'End time cannot be before start time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return null;
    }

    // Build recurrence rule
    final newRecurrenceRule = buildRecurrenceRule();

    // Handle recurring events - update doneOccurrences list
    List<DateTime> newDoneOccurrences = existingSchedule?.doneOccurrences ?? [];
    bool newIsDone = isDone.value;

    if (existingSchedule != null && existingSchedule!.isRecurring && tappedOccurrenceDate != null) {
      final normalizedDate = DateTime(tappedOccurrenceDate!.year, tappedOccurrenceDate!.month, tappedOccurrenceDate!.day);

      if (isDone.value) {
        if (!existingSchedule!.isOccurrenceDone(tappedOccurrenceDate!)) {
          newDoneOccurrences = [...existingSchedule!.doneOccurrences, normalizedDate];
        }
      } else {
        newDoneOccurrences = existingSchedule!.doneOccurrences.where((d) {
          final normalizedDone = DateTime(d.year, d.month, d.day);
          return !normalizedDone.isAtSameMomentAs(normalizedDate);
        }).toList();
      }
      newIsDone = existingSchedule!.isDone;
    }

    return ScheduleModel(
      id: existingSchedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      start: startDateTime,
      end: endDateTime,
      location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
      isAllDay: isAllDay.value,
      note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      colorValue: selectedColor.value.toARGB32(),
      recurrenceRule: newRecurrenceRule,
      exceptionDateList: existingSchedule?.exceptionDateList,
      isDone: newIsDone,
      doneOccurrences: newDoneOccurrences,
    );
  }

  /// Get human-readable recurrence description
  String getRecurrenceDescription() {
    if (recurrenceFrequency.value == RecurrenceFrequency.never) {
      return 'Never';
    }

    String desc = '';
    final interval = recurrenceInterval.value;

    switch (recurrenceFrequency.value) {
      case RecurrenceFrequency.daily:
        desc = interval == 1 ? 'Daily' : 'Every $interval days';
        break;
      case RecurrenceFrequency.weekly:
        if (selectedWeekDays.isEmpty) {
          desc = interval == 1 ? 'Weekly' : 'Every $interval weeks';
        } else {
          final days = selectedWeekDays.map((d) => _getWeekDayShort(d)).join(', ');
          desc = interval == 1 ? 'Weekly on $days' : 'Every $interval weeks on $days';
        }
        break;
      case RecurrenceFrequency.monthly:
        desc = interval == 1 ? 'Monthly on day ${monthlyDay.value}' : 'Every $interval months on day ${monthlyDay.value}';
        break;
      default:
        desc = 'Never';
    }

    return desc;
  }

  String getWeekDayName(WeekDay day) {
    switch (day) {
      case WeekDay.monday:
        return 'Monday';
      case WeekDay.tuesday:
        return 'Tuesday';
      case WeekDay.wednesday:
        return 'Wednesday';
      case WeekDay.thursday:
        return 'Thursday';
      case WeekDay.friday:
        return 'Friday';
      case WeekDay.saturday:
        return 'Saturday';
      case WeekDay.sunday:
        return 'Sunday';
    }
  }

  String _getWeekDayShort(WeekDay day) {
    switch (day) {
      case WeekDay.monday:
        return 'Mon';
      case WeekDay.tuesday:
        return 'Tue';
      case WeekDay.wednesday:
        return 'Wed';
      case WeekDay.thursday:
        return 'Thu';
      case WeekDay.friday:
        return 'Fri';
      case WeekDay.saturday:
        return 'Sat';
      case WeekDay.sunday:
        return 'Sun';
    }
  }
}
