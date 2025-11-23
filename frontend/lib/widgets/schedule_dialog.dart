import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/home.dart';
import '../models/schedule.dart';
import '../providers/calendar.dart';
import '../utils/datetime_format.dart';

class ScheduleDialog extends ConsumerWidget {
  final DateTime date;
  final HomeController homeController;
  final Schedule? existingSchedule;

  const ScheduleDialog({super.key, required this.date, required this.homeController, this.existingSchedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogWidth = MediaQuery.of(context).size.width * 0.8;
    final dialogHeight = MediaQuery.of(context).size.height * 0.4;

    final isEditing = existingSchedule != null;

    final title = TextEditingController(text: existingSchedule?.eventName ?? "");
    final location = TextEditingController(text: existingSchedule?.location ?? "");
    final startDate = TextEditingController(text: existingSchedule != null ? formatYMD(existingSchedule!.startDate) : formatYMD(date));
    final startTime = TextEditingController(
      text: existingSchedule != null ? formatTimeOfDayToHHMM(existingSchedule!.startTime) : formatTimeOfDayAMPM(const TimeOfDay(hour: 0, minute: 1)),
    );

    //final start = TextEditingController(text: (existingSchedule?.from ?? date.add(const Duration(hours: 9))).toString());
    final end = TextEditingController(text: (existingSchedule?.to ?? date.add(const Duration(hours: 10))).toString());

    if (isEditing) {
      return _buildEditDialog(context, ref, title, startDate, end);
    } else {
      return buildAddDialog(context, ref, dialogWidth, dialogHeight, title, location, startDate, startTime, end);
    }
  }

  Widget buildAddDialog(
    BuildContext context,
    WidgetRef ref,
    double dialogWidth,
    double dialogHeight,
    TextEditingController title,
    TextEditingController location,
    TextEditingController startDate,
    TextEditingController startTime,
    TextEditingController end,
  ) {
    return AlertDialog(
      title: const Text("Add Schedule"),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First Row: Title & Location
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: title,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: "Title",
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.title, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: location,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: "Location",
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100, // subtle background
                        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none, // remove default border
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Second Row: Date & Time Pickers
              Row(
                children: [
                  // Start Date
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: startDate,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          startDate.text = "${picked.year}-${picked.month}-${picked.day}";
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Start Date",
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.date_range, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100, // subtle background
                        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none, // remove default border
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Start Time
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: startTime,
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          startTime.text = formatTimeOfDayAMPM(time);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Start Time",
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100, // subtle background
                        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none, // remove default border
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // End Date
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: title,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          title.text = "${picked.year}-${picked.month}-${picked.day}";
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "End Date",
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // End Time
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: title,
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          title.text = time.format(context);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "End Time",
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // CANCEL BUTTON
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 12),

              // ADD BUTTON
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {}, // your function
                child: const Text("Add"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------
  // ADD SCHEDULE UI
  // ------------------------------------------------
  // Widget _buildAddDialog(BuildContext context, WidgetRef ref, TextEditingController title, TextEditingController start, TextEditingController end) {
  //   return AlertDialog(
  //     title: const Text("Add Schedule"),
  //     content: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         TextField(
  //           controller: title,
  //           decoration: const InputDecoration(labelText: "Title"),
  //         ),
  //         TextField(
  //           controller: start,
  //           decoration: const InputDecoration(labelText: "Start"),
  //         ),
  //         TextField(
  //           controller: end,
  //           decoration: const InputDecoration(labelText: "End"),
  //         ),
  //       ],
  //     ),
  //     actions: [
  //       TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
  //       ElevatedButton(
  //         child: const Text("Add"),
  //         onPressed: () {
  //           ref
  //               .read(scheduleListProvider.notifier)
  //               .addSchedule(
  //                 homeController.createSchedule(
  //                   title.text.isEmpty ? "(No Title)" : title.text,
  //                   '',
  //                   DateTime.tryParse(start.text) ?? date.add(const Duration(hours: 9)),
  //                   DateTime.tryParse(end.text) ?? date.add(const Duration(hours: 10)),
  //                 ),
  //               );
  //           Navigator.pop(context);
  //         },
  //       ),
  //     ],
  //   );
  // }

  // ------------------------------------------------
  // EDIT SCHEDULE UI (different design)
  // ------------------------------------------------
  Widget _buildEditDialog(BuildContext context, WidgetRef ref, TextEditingController title, TextEditingController startDate, TextEditingController endDate) {
    final schedule = existingSchedule!;

    final dialogWidth = MediaQuery.of(context).size.width * 0.8;
    final dialogHeight = MediaQuery.of(context).size.height * 0.5;

    // Separate time controllers
    final startTime = TextEditingController(
      text: "${schedule.startDate.hour.toString().padLeft(2, '0')}:${schedule.startDate.minute.toString().padLeft(2, '0')}",
    );
    final endTime = TextEditingController(text: "${schedule.to.hour.toString().padLeft(2, '0')}:${schedule.to.minute.toString().padLeft(2, '0')}");

    return AlertDialog(
      title: const Text("Edit Schedule"),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              TextField(
                controller: title,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: "Title",
                  prefixIcon: const Icon(Icons.title, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 15),

              // DATE/TIME ROW
              Row(
                children: [
                  // Start date
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: startDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: schedule.startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          startDate.text = formatYMD(picked);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Start Date",
                        prefixIcon: const Icon(Icons.date_range, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Start time
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: startTime,
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(schedule.startDate));
                        if (picked != null) {
                          startTime.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Start Time",
                        prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  // End date
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: endDate,
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: schedule.to, firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (picked != null) {
                          endDate.text = formatYMD(picked);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "End Date",
                        prefixIcon: const Icon(Icons.date_range, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // End time
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: endTime,
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(schedule.to));
                        if (picked != null) {
                          endTime.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "End Time",
                        prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // BUTTONS
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Delete
            TextButton(
              onPressed: () {
                ref.read(scheduleListProvider.notifier).removeSchedule(schedule);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),

            const SizedBox(width: 8),

            // Cancel
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),

            const SizedBox(width: 8),

            // Save
            FilledButton(
              onPressed: () {
                final notifier = ref.read(scheduleListProvider.notifier);

                DateTime s = DateTime.parse("${startDate.text} ${startTime.text}:00");
                DateTime e = DateTime.parse("${endDate.text} ${endTime.text}:00");

                final startTimeParts = startTime.text.split(':').map((e) => int.parse(e)).toList();

                notifier.removeSchedule(schedule);
                notifier.addSchedule(
                  homeController.createSchedule(
                    title.text.isEmpty ? "(No Title)" : title.text,
                    schedule.location,
                    s,
                    TimeOfDay(hour: startTimeParts[0], minute: startTimeParts[1]),
                    e,
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ],
    );
  }
}
