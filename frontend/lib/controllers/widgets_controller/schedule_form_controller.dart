import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/schedule_model.dart';

/// Recurrence frequency options
enum RecurrenceFrequency { none, daily, weekly, monthly, yearly, custom }

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
  final Rx<RecurrenceFrequency> recurrenceFrequency = RecurrenceFrequency.none.obs;
  final RxInt recurrenceInterval = 1.obs; // Every X days/weeks/months/years
  final RxList<WeekDay> selectedWeekDays = <WeekDay>[].obs; // For weekly recurrence
  final RxInt recurrenceCount = 10.obs; // Number of occurrences (0 = forever)
  final Rx<DateTime?> recurrenceEndDate = Rx<DateTime?>(null); // End by date
  final RxBool useEndDate = false.obs; // true = end by date, false = end by count
  final RxInt monthlyOption = 0.obs; // 0 = day of month, 1 = day of week (e.g., 2nd Tuesday)

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

    // Parse existing recurrence rule
    if (schedule?.recurrenceRule != null && schedule!.recurrenceRule!.isNotEmpty) {
      _parseRecurrenceRule(schedule.recurrenceRule!);
    } else {
      // Reset recurrence state
      recurrenceFrequency.value = RecurrenceFrequency.none;
      recurrenceInterval.value = 1;
      selectedWeekDays.clear();
      recurrenceCount.value = 10;
      recurrenceEndDate.value = null;
      useEndDate.value = false;
      monthlyOption.value = 0;
    }

    // For recurring events, check if this specific occurrence is done
    // For non-recurring events, use the isDone flag directly
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
      case 'YEARLY':
        recurrenceFrequency.value = RecurrenceFrequency.yearly;
        break;
      default:
        recurrenceFrequency.value = RecurrenceFrequency.none;
    }

    // Parse interval
    if (ruleMap.containsKey('INTERVAL')) {
      recurrenceInterval.value = int.tryParse(ruleMap['INTERVAL']!) ?? 1;
      if (recurrenceInterval.value > 1) {
        recurrenceFrequency.value = RecurrenceFrequency.custom;
      }
    } else {
      recurrenceInterval.value = 1;
    }

    // Parse count
    if (ruleMap.containsKey('COUNT')) {
      recurrenceCount.value = int.tryParse(ruleMap['COUNT']!) ?? 10;
      useEndDate.value = false;
    }

    // Parse until date
    if (ruleMap.containsKey('UNTIL')) {
      try {
        final untilStr = ruleMap['UNTIL']!;
        // Format: YYYYMMDDTHHMMSSZ or YYYYMMDD
        if (untilStr.length >= 8) {
          final year = int.parse(untilStr.substring(0, 4));
          final month = int.parse(untilStr.substring(4, 6));
          final day = int.parse(untilStr.substring(6, 8));
          recurrenceEndDate.value = DateTime(year, month, day);
          useEndDate.value = true;
        }
      } catch (_) {}
    }

    // Parse BYDAY for weekly recurrence
    if (ruleMap.containsKey('BYDAY')) {
      selectedWeekDays.clear();
      final days = ruleMap['BYDAY']!.split(',');
      for (final day in days) {
        // Remove any numeric prefix (e.g., "2TU" -> "TU")
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
      if (recurrenceFrequency.value == RecurrenceFrequency.weekly && selectedWeekDays.length > 1) {
        recurrenceFrequency.value = RecurrenceFrequency.custom;
      }
    }

    // Parse BYSETPOS for monthly "nth weekday" option
    if (ruleMap.containsKey('BYSETPOS') || (ruleMap.containsKey('BYDAY') && recurrenceFrequency.value == RecurrenceFrequency.monthly)) {
      monthlyOption.value = 1; // nth weekday of month
    } else {
      monthlyOption.value = 0; // day of month
    }
  }

  /// Build recurrence rule string (RFC 5545 format)
  String? buildRecurrenceRule() {
    if (recurrenceFrequency.value == RecurrenceFrequency.none) {
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
      case RecurrenceFrequency.yearly:
        parts.add('FREQ=YEARLY');
        break;
      case RecurrenceFrequency.custom:
        // Determine base frequency from context
        if (selectedWeekDays.isNotEmpty) {
          parts.add('FREQ=WEEKLY');
        } else if (monthlyOption.value > 0) {
          parts.add('FREQ=MONTHLY');
        } else {
          parts.add('FREQ=DAILY');
        }
        break;
      default:
        return null;
    }

    // Interval (only if > 1 or custom)
    if (recurrenceInterval.value > 1) {
      parts.add('INTERVAL=${recurrenceInterval.value}');
    }

    // BYDAY for weekly recurrence
    if ((recurrenceFrequency.value == RecurrenceFrequency.weekly || recurrenceFrequency.value == RecurrenceFrequency.custom) && selectedWeekDays.isNotEmpty) {
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

    // Monthly options
    if (recurrenceFrequency.value == RecurrenceFrequency.monthly && monthlyOption.value == 1) {
      // nth weekday of month (e.g., 2nd Tuesday)
      final weekOfMonth = ((startDate.value.day - 1) ~/ 7) + 1;
      final weekday = startDate.value.weekday;
      final dayCode = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'][weekday - 1];
      parts.add('BYDAY=$weekOfMonth$dayCode');
    }

    // End condition
    if (useEndDate.value && recurrenceEndDate.value != null) {
      final d = recurrenceEndDate.value!;
      final untilStr = '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T235959Z';
      parts.add('UNTIL=$untilStr');
    } else if (recurrenceCount.value > 0) {
      parts.add('COUNT=${recurrenceCount.value}');
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
    // Auto-adjust end date if needed
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
  }

  void toggleWeekDay(WeekDay day) {
    if (selectedWeekDays.contains(day)) {
      selectedWeekDays.remove(day);
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

  void setUseEndDate(bool value) {
    useEndDate.value = value;
  }

  void setMonthlyOption(int option) {
    monthlyOption.value = option;
  }

  /// Validate and build the schedule model, returns null if validation fails
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
      // For recurring events, update the specific occurrence in doneOccurrences list
      final normalizedDate = DateTime(tappedOccurrenceDate!.year, tappedOccurrenceDate!.month, tappedOccurrenceDate!.day);

      if (isDone.value) {
        // Add to doneOccurrences if not already present
        if (!existingSchedule!.isOccurrenceDone(tappedOccurrenceDate!)) {
          newDoneOccurrences = [...existingSchedule!.doneOccurrences, normalizedDate];
        }
      } else {
        // Remove from doneOccurrences
        newDoneOccurrences = existingSchedule!.doneOccurrences.where((d) {
          final normalizedDone = DateTime(d.year, d.month, d.day);
          return !normalizedDone.isAtSameMomentAs(normalizedDate);
        }).toList();
      }

      // For recurring events, isDone field stays as original (it's not used for individual occurrences)
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
    if (recurrenceFrequency.value == RecurrenceFrequency.none) {
      return 'Does not repeat';
    }

    String desc = '';
    final interval = recurrenceInterval.value;

    switch (recurrenceFrequency.value) {
      case RecurrenceFrequency.daily:
        desc = interval == 1 ? 'Every day' : 'Every $interval days';
        break;
      case RecurrenceFrequency.weekly:
        if (selectedWeekDays.isEmpty) {
          desc = interval == 1 ? 'Every week' : 'Every $interval weeks';
        } else if (selectedWeekDays.length == 1) {
          desc = interval == 1
              ? 'Every week on ${_getWeekDayName(selectedWeekDays.first)}'
              : 'Every $interval weeks on ${_getWeekDayName(selectedWeekDays.first)}';
        } else {
          final days = selectedWeekDays.map((d) => _getWeekDayShort(d)).join(', ');
          desc = interval == 1 ? 'Every week on $days' : 'Every $interval weeks on $days';
        }
        break;
      case RecurrenceFrequency.monthly:
        if (monthlyOption.value == 1) {
          final weekOfMonth = ((startDate.value.day - 1) ~/ 7) + 1;
          final ordinal = _getOrdinal(weekOfMonth);
          final weekdayName = _getWeekDayName(WeekDay.values[startDate.value.weekday - 1]);
          desc = interval == 1 ? 'Every month on the $ordinal $weekdayName' : 'Every $interval months on the $ordinal $weekdayName';
        } else {
          desc = interval == 1 ? 'Every month on day ${startDate.value.day}' : 'Every $interval months on day ${startDate.value.day}';
        }
        break;
      case RecurrenceFrequency.yearly:
        desc = interval == 1 ? 'Every year' : 'Every $interval years';
        break;
      case RecurrenceFrequency.custom:
        desc = 'Custom';
        break;
      default:
        desc = 'Does not repeat';
    }

    // Add end condition
    if (useEndDate.value && recurrenceEndDate.value != null) {
      desc += ', until ${recurrenceEndDate.value!.day}/${recurrenceEndDate.value!.month}/${recurrenceEndDate.value!.year}';
    } else if (recurrenceCount.value > 0) {
      desc += ', ${recurrenceCount.value} times';
    }

    return desc;
  }

  String _getWeekDayName(WeekDay day) {
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

  String _getOrdinal(int n) {
    if (n == 1) return '1st';
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }
}
