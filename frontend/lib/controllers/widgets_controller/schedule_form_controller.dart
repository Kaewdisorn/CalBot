import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/schedule_model.dart';

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

  // Edit mode tracking
  ScheduleModel? existingSchedule;
  bool get isEditMode => existingSchedule != null;

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
  void initialize({ScheduleModel? schedule, DateTime? initialDate}) {
    existingSchedule = schedule;
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
    isDone.value = schedule?.isDone ?? false;
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

    return ScheduleModel(
      id: existingSchedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      start: startDateTime,
      end: endDateTime,
      location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
      isAllDay: isAllDay.value,
      note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      colorValue: selectedColor.value.toARGB32(),
      recurrenceRule: existingSchedule?.recurrenceRule,
      exceptionDateList: existingSchedule?.exceptionDateList,
      isDone: isDone.value,
    );
  }
}
