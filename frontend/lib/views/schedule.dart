import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../controllers/home.dart';
import '../providers/schedule.dart';
import '../utils/datetime_format.dart';
import '../widgets/date_picker_textfield.dart';
import '../widgets/time_picker_textfield.dart';
import 'recurrence.dart';

class ScheduleDialog extends ConsumerStatefulWidget {
  final DateTime date;
  final HomeController homeController;
  final Appointment? existingAppointment;

  const ScheduleDialog({super.key, required this.date, required this.homeController, this.existingAppointment});

  @override
  ConsumerState<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends ConsumerState<ScheduleDialog> {
  late final TextEditingController titleController;
  late final TextEditingController locationController;
  late final TextEditingController startDateController;
  late final TextEditingController startTimeController;
  late final TextEditingController endDateController;
  late final TextEditingController endTimeController;
  late final TextEditingController descriptionController;

  bool allDay = false;
  bool isDone = false;

  final List<Color> paletteColors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink];

  late Color selectedColor;

  String? _prevStartTimeText;
  String? _prevEndTimeText;

  bool repeat = false;
  Map<String, dynamic> recurrenceDetail = {};

  @override
  void initState() {
    super.initState();
    final a = widget.existingAppointment;

    titleController = TextEditingController(text: a?.subject ?? "");
    locationController = TextEditingController(text: a?.location ?? "");
    descriptionController = TextEditingController(text: a != null ? jsonDecode(a.notes ?? '{}')['description'] ?? '' : '');
    selectedColor = a?.color ?? paletteColors.first;

    final start = a?.startTime ?? widget.date;
    final end = a?.endTime ?? widget.date.add(const Duration(hours: 1));

    startDateController = TextEditingController(text: formatYMD(start));
    endDateController = TextEditingController(text: formatYMD(end));
    startTimeController = TextEditingController(text: formatTimeOfDayAMPM(TimeOfDay.fromDateTime(start)));
    endTimeController = TextEditingController(text: formatTimeOfDayAMPM(TimeOfDay.fromDateTime(end)));

    isDone = a != null ? jsonDecode(a.notes ?? '{}')['isDone'] ?? false : false;

    // Auto-check allDay if full day
    if (start.hour == 0 && start.minute == 0 && end.hour == 23 && end.minute == 59) {
      allDay = true;
      _prevStartTimeText = startTimeController.text;
      _prevEndTimeText = endTimeController.text;
    }

    startDateController.addListener(_onStartDateChanged);
  }

  void _onStartDateChanged() {
    if (allDay) {
      endDateController.text = startDateController.text;
    }
  }

  @override
  void dispose() {
    startDateController.removeListener(_onStartDateChanged);

    titleController.dispose();
    locationController.dispose();
    startDateController.dispose();
    startTimeController.dispose();
    endDateController.dispose();
    endTimeController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  TimeOfDay? parseTimeOfDay(String timeStr) {
    try {
      timeStr = timeStr.trim().toLowerCase();
      final isPM = timeStr.contains('pm');
      final isAM = timeStr.contains('am');
      timeStr = timeStr.replaceAll(RegExp(r'\s*(am|pm)'), '');

      int hour = 0, minute = 0;
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);
      } else if (parts.length == 1) {
        hour = int.parse(parts[0]);
      } else {
        return null;
      }

      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  void showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  void pickCustomColor() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pick Custom Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) => setState(() => selectedColor = color),
            labelTypes: const [],
            enableAlpha: false,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAppointment != null;
    final dialogWidth = MediaQuery.of(context).size.width * 0.7;
    final dialogHeight = MediaQuery.of(context).size.height * 0.55;

    return AlertDialog(
      title: Text(isEditing ? "Edit Schedule" : "Add Schedule"),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title & Location
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        prefixIcon: const Icon(Icons.title),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: "Location",
                        prefixIcon: const Icon(Icons.location_on),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dates & Times
              Row(
                children: [
                  Expanded(
                    child: DatePickerTextField(controller: startDateController, label: "Start Date", initialDate: widget.date),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TimePickerTextField(
                      controller: startTimeController,
                      label: "Start Time",
                      initialTime: const TimeOfDay(hour: 0, minute: 1),
                      enabled: !allDay,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DatePickerTextField(controller: endDateController, label: "End Date", initialDate: widget.date),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TimePickerTextField(
                      controller: endTimeController,
                      label: "End Time",
                      initialTime: const TimeOfDay(hour: 23, minute: 59),
                      enabled: !allDay,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // All Day & Done
              Row(
                children: [
                  Checkbox(
                    value: allDay,
                    onChanged: (value) {
                      setState(() {
                        final v = value ?? false;
                        if (v && !allDay) {
                          _prevStartTimeText = startTimeController.text;
                          _prevEndTimeText = endTimeController.text;
                          startTimeController.text = "00:00";
                          endTimeController.text = "23:59";
                          endDateController.text = startDateController.text;
                        } else if (!v && allDay) {
                          if (_prevStartTimeText != null) startTimeController.text = _prevStartTimeText!;
                          if (_prevEndTimeText != null) endTimeController.text = _prevEndTimeText!;
                        }
                        allDay = v;
                      });
                    },
                  ),
                  const Text("All Day"),
                  const SizedBox(width: 16),
                  Checkbox(value: isDone, onChanged: (v) => setState(() => isDone = v ?? false)),
                  const Text("Mark as Done"),
                  Checkbox(
                    value: repeat,
                    onChanged: (v) {
                      if (v == true) {
                        showDialog(
                          context: context,
                          builder: (context) => RecurrenceDialog(
                            initialRecurrence: recurrenceDetail,
                            onSave: (rec) {
                              setState(() {
                                repeat = true;
                                recurrenceDetail = rec;
                              });
                            },
                          ),
                        );
                      } else {
                        setState(() {
                          repeat = false;
                          recurrenceDetail = {};
                        });
                      }
                    },
                  ),
                  const Text("Repeat"),
                  if (repeat && recurrenceDetail.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(formatRecurrenceSummary(recurrenceDetail), style: const TextStyle(decoration: TextDecoration.underline)),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              TextField(
                controller: descriptionController,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: "Description",
                  prefix: Padding(padding: const EdgeInsets.only(top: 12, right: 8), child: const Icon(Icons.description)),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              // Color Palette + Custom
              Row(
                children: [
                  ...paletteColors.map(
                    (c) => GestureDetector(
                      onTap: () => setState(() => selectedColor = c),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: selectedColor == c ? Border.all(width: 3, color: Colors.black) : null,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: pickCustomColor,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Live preview of selected color + line-through if done
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        titleController.text.isEmpty ? "Sample Title" : titleController.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isEditing)
              TextButton(
                onPressed: () {
                  ref.read(scheduleListProvider.notifier).removeAppointment(widget.existingAppointment!);
                  Navigator.pop(context);
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(width: 8),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            const SizedBox(width: 8),
            FilledButton(onPressed: saveAppointment, child: Text(isEditing ? "Save" : "Add")),
          ],
        ),
      ],
    );
  }

  void saveAppointment() {
    final notifier = ref.read(scheduleListProvider.notifier);

    DateTime? startDateParsed;
    DateTime? endDateParsed;
    try {
      startDateParsed = DateTime.parse(startDateController.text);
      endDateParsed = DateTime.parse(endDateController.text);
    } catch (_) {
      showErrorDialog("Invalid date format.");
      return;
    }

    final startTOD = parseTimeOfDay(startTimeController.text);
    final endTOD = parseTimeOfDay(endTimeController.text);

    if (startTOD == null || endTOD == null) {
      showErrorDialog("Invalid time format.");
      return;
    }

    final startDateTime = DateTime(startDateParsed.year, startDateParsed.month, startDateParsed.day, startTOD.hour, startTOD.minute);
    final endDateTime = DateTime(endDateParsed.year, endDateParsed.month, endDateParsed.day, endTOD.hour, endTOD.minute);

    if (endDateTime.isBefore(startDateTime)) {
      showErrorDialog("End date/time must be after start date/time.");
      return;
    }

    if (widget.existingAppointment != null) {
      notifier.removeAppointment(widget.existingAppointment!);
    }

    final newAppointment = widget.homeController.createAppointment(
      title: titleController.text.isEmpty ? "(No Title)" : titleController.text,
      location: locationController.text,
      startDate: startDateParsed,
      startTime: startTOD,
      endDate: endDateParsed,
      endTime: endTOD,
      description: descriptionController.text,
      color: selectedColor,
      isAllDay: allDay,
      isDone: isDone,
    );

    notifier.addAppointment(newAppointment);

    if (mounted) Navigator.pop(context);
  }

  String formatRecurrenceSummary(Map<String, dynamic> recurrenceDetail) {
    if (recurrenceDetail.isEmpty) return '';

    final type = recurrenceDetail['type'] ?? '';
    final interval = recurrenceDetail['interval'] ?? 1;

    switch (type) {
      case 'Daily':
        return "Every $interval day${interval > 1 ? 's' : ''}";
      case 'Weekly':
        final days = (recurrenceDetail['weekdays'] as List<int>?)?.map((d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1]).toList() ?? [];
        final daysStr = days.isNotEmpty ? days.join(', ') : '?';
        return "Every $interval week${interval > 1 ? 's' : ''} on $daysStr";
      case 'Monthly':
        final monthlyOption = recurrenceDetail['monthlyOption'] ?? 'DayOfMonth';
        if (monthlyOption == 'DayOfMonth') {
          final day = recurrenceDetail['monthlyDay'] ?? '?';
          return "Every $interval month${interval > 1 ? 's' : ''} on day $day";
        } else {
          return "Every $interval month${interval > 1 ? 's' : ''} on ${monthlyOption}";
        }
      default:
        return '';
    }
  }
}
