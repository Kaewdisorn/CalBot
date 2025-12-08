import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/schedule_model.dart';
import 'auth_controller.dart';

/// Recurrence frequency options
enum RecurrenceFrequency { never, daily, weekly, monthly }

/// Recurrence end type
enum RecurrenceEndType { never, until, count }

/// Days of week for weekly recurrence
enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

/// Monthly repeat mode
enum MonthlyRepeatMode { byDay, byWeekPosition }

/// Week position in month
enum WeekPosition { first, second, third, fourth, last }

class ScheduleFormController extends GetxController {
  // Get AuthController to access logged-in user data
  final AuthController _authController = Get.find<AuthController>();

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
  final Rx<MonthlyRepeatMode> monthlyRepeatMode = MonthlyRepeatMode.byDay.obs;
  final Rx<WeekPosition> monthlyWeekPosition = WeekPosition.first.obs;
  final Rx<WeekDay> monthlyWeekDay = WeekDay.monday.obs;

  // Edit mode tracking
  ScheduleModel? existingSchedule;
  bool get isEditMode => existingSchedule != null;

  // For recurring events - track which occurrence was tapped
  DateTime? tappedOccurrenceDate;

  // Custom color input controller
  late TextEditingController customColorController;

  // Color palette for schedule - Top 5 best colors
  static const List<Color> colorPalette = [
    Color(0xFF42A5F5), // Blue
    Color(0xFF66BB6A), // Green
    Color(0xFFEF5350), // Red
    Color(0xFFAB47BC), // Purple
    Color(0xFFFF7043), // Orange
  ];

  /// Initialize the controller with optional existing schedule or initial date
  void initialize({ScheduleModel? schedule, DateTime? initialDate, DateTime? tappedOccurrenceDate}) {
    existingSchedule = schedule;
    this.tappedOccurrenceDate = tappedOccurrenceDate;
    final now = initialDate ?? DateTime.now();

    titleController = TextEditingController(text: schedule?.title ?? '');
    locationController = TextEditingController(text: schedule?.location ?? '');
    noteController = TextEditingController(text: schedule?.note ?? '');
    customColorController = TextEditingController();

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

    // Parse BYDAY for weekly recurrence (must be parsed before COUNT adjustment)
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

    // Parse count (after BYDAY so we can adjust for weekly recurrence)
    if (ruleMap.containsKey('COUNT')) {
      int rawCount = int.tryParse(ruleMap['COUNT']!) ?? 10;
      // For weekly recurrence with multiple days, divide by number of days to get weeks
      if (recurrenceFrequency.value == RecurrenceFrequency.weekly && selectedWeekDays.length > 1) {
        recurrenceCount.value = (rawCount / selectedWeekDays.length).ceil();
      } else {
        recurrenceCount.value = rawCount;
      }
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

    // Parse BYMONTHDAY for monthly recurrence
    if (ruleMap.containsKey('BYMONTHDAY')) {
      monthlyDay.value = int.tryParse(ruleMap['BYMONTHDAY']!) ?? startDate.value.day;
      monthlyRepeatMode.value = MonthlyRepeatMode.byDay;
    }

    // Parse BYDAY with week position for monthly recurrence (e.g., 1MO, 2TU, -1FR)
    if (recurrenceFrequency.value == RecurrenceFrequency.monthly && ruleMap.containsKey('BYDAY')) {
      final byday = ruleMap['BYDAY']!;
      monthlyRepeatMode.value = MonthlyRepeatMode.byWeekPosition;
      // Parse week position
      if (byday.startsWith('-1')) {
        monthlyWeekPosition.value = WeekPosition.last;
      } else if (byday.startsWith('1')) {
        monthlyWeekPosition.value = WeekPosition.first;
      } else if (byday.startsWith('2')) {
        monthlyWeekPosition.value = WeekPosition.second;
      } else if (byday.startsWith('3')) {
        monthlyWeekPosition.value = WeekPosition.third;
      } else if (byday.startsWith('4')) {
        monthlyWeekPosition.value = WeekPosition.fourth;
      }
      // Parse weekday
      final dayCode = byday.replaceAll(RegExp(r'[0-9-]'), '');
      switch (dayCode) {
        case 'MO':
          monthlyWeekDay.value = WeekDay.monday;
          break;
        case 'TU':
          monthlyWeekDay.value = WeekDay.tuesday;
          break;
        case 'WE':
          monthlyWeekDay.value = WeekDay.wednesday;
          break;
        case 'TH':
          monthlyWeekDay.value = WeekDay.thursday;
          break;
        case 'FR':
          monthlyWeekDay.value = WeekDay.friday;
          break;
        case 'SA':
          monthlyWeekDay.value = WeekDay.saturday;
          break;
        case 'SU':
          monthlyWeekDay.value = WeekDay.sunday;
          break;
      }
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

    // Monthly recurrence - by day or by week position
    if (recurrenceFrequency.value == RecurrenceFrequency.monthly) {
      if (monthlyRepeatMode.value == MonthlyRepeatMode.byDay) {
        parts.add('BYMONTHDAY=${monthlyDay.value}');
      } else {
        // By week position (e.g., 1MO = first Monday, -1FR = last Friday)
        String posStr;
        switch (monthlyWeekPosition.value) {
          case WeekPosition.first:
            posStr = '1';
            break;
          case WeekPosition.second:
            posStr = '2';
            break;
          case WeekPosition.third:
            posStr = '3';
            break;
          case WeekPosition.fourth:
            posStr = '4';
            break;
          case WeekPosition.last:
            posStr = '-1';
            break;
        }
        String dayStr;
        switch (monthlyWeekDay.value) {
          case WeekDay.monday:
            dayStr = 'MO';
            break;
          case WeekDay.tuesday:
            dayStr = 'TU';
            break;
          case WeekDay.wednesday:
            dayStr = 'WE';
            break;
          case WeekDay.thursday:
            dayStr = 'TH';
            break;
          case WeekDay.friday:
            dayStr = 'FR';
            break;
          case WeekDay.saturday:
            dayStr = 'SA';
            break;
          case WeekDay.sunday:
            dayStr = 'SU';
            break;
        }
        parts.add('BYDAY=$posStr$dayStr');
      }
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
        // For weekly recurrence with multiple days, COUNT means number of weeks
        // So we multiply by the number of selected days to get total occurrences
        if (recurrenceFrequency.value == RecurrenceFrequency.weekly && selectedWeekDays.length > 1) {
          final totalOccurrences = recurrenceCount.value * selectedWeekDays.length;
          parts.add('COUNT=$totalOccurrences');
        } else {
          parts.add('COUNT=${recurrenceCount.value}');
        }
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
    customColorController.dispose();
    super.onClose();
  }

  /// Apply custom color from hex input
  void applyCustomColor() {
    final text = customColorController.text.trim();
    if (text.isEmpty) return;

    // Remove # if present and validate hex format
    final hex = text.replaceAll('#', '').toUpperCase();
    final hexRegex = RegExp(r'^[0-9A-F]{6}$');

    if (hexRegex.hasMatch(hex)) {
      final colorValue = int.parse('FF$hex', radix: 16);
      selectedColor.value = Color(colorValue);
      customColorController.clear();
    } else {
      Get.snackbar(
        'Invalid Color',
        'Please enter a valid 6-digit hex code (e.g., FF5733)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
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
    // Set default monthly options
    if (freq == RecurrenceFrequency.monthly) {
      monthlyDay.value = startDate.value.day;
      monthlyWeekDay.value = WeekDay.values[startDate.value.weekday - 1];
      // Calculate week position
      final weekOfMonth = ((startDate.value.day - 1) ~/ 7);
      monthlyWeekPosition.value = WeekPosition.values[weekOfMonth.clamp(0, 3)];
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

  void setMonthlyRepeatMode(MonthlyRepeatMode mode) {
    monthlyRepeatMode.value = mode;
  }

  void setMonthlyWeekPosition(WeekPosition position) {
    monthlyWeekPosition.value = position;
  }

  void setMonthlyWeekDay(WeekDay day) {
    monthlyWeekDay.value = day;
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
      uid: existingSchedule?.uid ?? DateTime.now().millisecondsSinceEpoch.toString(),
      gid: existingSchedule?.gid ?? _authController.userGid.value,
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
        if (monthlyRepeatMode.value == MonthlyRepeatMode.byDay) {
          desc = interval == 1 ? 'Monthly on day ${monthlyDay.value}' : 'Every $interval months on day ${monthlyDay.value}';
        } else {
          final posName = _getWeekPositionName(monthlyWeekPosition.value);
          final dayName = getWeekDayName(monthlyWeekDay.value);
          desc = interval == 1 ? 'Monthly on $posName $dayName' : 'Every $interval months on $posName $dayName';
        }
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

  String _getWeekPositionName(WeekPosition pos) {
    switch (pos) {
      case WeekPosition.first:
        return 'first';
      case WeekPosition.second:
        return 'second';
      case WeekPosition.third:
        return 'third';
      case WeekPosition.fourth:
        return 'fourth';
      case WeekPosition.last:
        return 'last';
    }
  }
}
