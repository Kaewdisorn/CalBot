import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/home.dart';
import '../models/schedule.dart';
import '../providers/calendar.dart';
import '../utils/datetime_format.dart';
import '../widgets/date_picker_textfield.dart';
import '../widgets/time_picker_textfield.dart';

class ScheduleDialog extends ConsumerStatefulWidget {
  final DateTime date;
  final HomeController homeController;
  final Schedule? existingSchedule;

  const ScheduleDialog({super.key, required this.date, required this.homeController, this.existingSchedule});

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

  final Map<String, Color> colorOptions = {
    "Blue": Colors.blue,
    "Red": Colors.red,
    "Green": Colors.green,
    "Orange": Colors.orange,
    "Purple": Colors.purple,
    "Teal": Colors.teal,
    "Pink": Colors.pink,
  };

  String selectedColorName = "Blue"; // default
  Color get selectedColor => colorOptions[selectedColorName]!;

  @override
  void initState() {
    super.initState();

    final s = widget.existingSchedule;

    titleController = TextEditingController(text: s?.eventName ?? "");
    locationController = TextEditingController(text: s?.location ?? "");
    startDateController = TextEditingController(text: s != null ? formatYMD(s.startDate) : formatYMD(widget.date));
    startTimeController = TextEditingController(text: s != null ? formatTimeOfDayAMPM(s.startTime) : formatTimeOfDayAMPM(const TimeOfDay(hour: 0, minute: 1)));
    endDateController = TextEditingController(text: s != null ? formatYMD(s.endDate) : formatYMD(widget.date));
    endTimeController = TextEditingController(text: s != null ? formatTimeOfDayAMPM(s.endTime) : formatTimeOfDayAMPM(const TimeOfDay(hour: 23, minute: 59)));
    descriptionController = TextEditingController(text: s?.description ?? "");

    // Auto-check allDay if times are full day
    if (s != null && s.startTime.hour == 0 && s.startTime.minute == 0 && s.endTime.hour == 23 && s.endTime.minute == 59) {
      allDay = true;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    startDateController.dispose();
    startTimeController.dispose();
    endDateController.dispose();
    endTimeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ---------------- Helper Methods ----------------

  TimeOfDay? parseTimeOfDay(String timeStr) {
    try {
      timeStr = timeStr.trim().toLowerCase();
      final isPM = timeStr.contains('pm');
      final isAM = timeStr.contains('am');

      timeStr = timeStr.replaceAll(RegExp(r'\s*(am|pm)'), '');

      int hour = 0;
      int minute = 0;

      final parts = timeStr.split(':');
      if (parts.length == 2) {
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);
      } else if (parts.length == 1) {
        hour = int.parse(parts[0]);
        minute = 0;
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

  // ---------------- Build Dialog ----------------

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSchedule != null;
    final dialogWidth = MediaQuery.of(context).size.width * 0.8;
    final dialogHeight = MediaQuery.of(context).size.height * 0.6;

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
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              // All Day Checkbox
              Row(
                children: [
                  Checkbox(
                    value: allDay,
                    onChanged: (value) {
                      setState(() {
                        allDay = value ?? false;
                        if (allDay) {
                          startTimeController.text = "00:00";
                          endTimeController.text = "23:59";
                        }
                      });
                    },
                  ),
                  const Text("All Day"),
                ],
              ),
              const SizedBox(height: 16),

              // Description (Multiline)
              TextField(
                controller: descriptionController,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: "Description",
                  prefix: Padding(padding: const EdgeInsets.only(top: 12, right: 8), child: Icon(Icons.description)),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Color Dropdown with hintText
              DropdownButtonFormField<String>(
                initialValue: selectedColorName,
                decoration: InputDecoration(
                  hintText: "Select Event Color",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
                items: colorOptions.keys.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(color: colorOptions[name], shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedColorName = value;
                    });
                  }
                },
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
                  ref.read(scheduleListProvider.notifier).removeSchedule(widget.existingSchedule!);
                  Navigator.pop(context);
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(width: 8),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            const SizedBox(width: 8),
            FilledButton(onPressed: saveSchedule, child: Text(isEditing ? "Save" : "Add")),
          ],
        ),
      ],
    );
  }

  void saveSchedule() {
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

    if (widget.existingSchedule != null) {
      notifier.removeSchedule(widget.existingSchedule!);
    }

    notifier.addSchedule(
      widget.homeController.createSchedule(
        titleController.text.isEmpty ? "(No Title)" : titleController.text,
        locationController.text,
        startDateTime,
        startTOD,
        endDateTime,
        endTOD,
        descriptionController.text,
        isAllDay: allDay,
        color: selectedColor,
      ),
    );

    if (mounted) Navigator.pop(context);
  }
}
