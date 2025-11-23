import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/home.dart';
import '../models/schedule.dart';
import '../providers/calendar.dart';

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
    final start = TextEditingController(text: (existingSchedule?.from ?? date.add(const Duration(hours: 9))).toString());
    final end = TextEditingController(text: (existingSchedule?.to ?? date.add(const Duration(hours: 10))).toString());

    if (isEditing) {
      return _buildEditDialog(context, ref, title, start, end);
    } else {
      // return _buildAddDialog(context, ref, title, start, end);
      return buildAddDialog(context, ref, dialogWidth, dialogHeight, title, location, start, end);
    }
  }

  Widget buildAddDialog(
    BuildContext context,
    WidgetRef ref,
    double dialogWidth,
    double dialogHeight,
    TextEditingController title,
    TextEditingController location,
    TextEditingController start,
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
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // ADD SCHEDULE UI
  // ------------------------------------------------
  Widget _buildAddDialog(BuildContext context, WidgetRef ref, TextEditingController title, TextEditingController start, TextEditingController end) {
    return AlertDialog(
      title: const Text("Add Schedule"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: title,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: start,
            decoration: const InputDecoration(labelText: "Start"),
          ),
          TextField(
            controller: end,
            decoration: const InputDecoration(labelText: "End"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          child: const Text("Add"),
          onPressed: () {
            ref
                .read(scheduleListProvider.notifier)
                .addSchedule(
                  homeController.createSchedule(
                    title.text.isEmpty ? "(No Title)" : title.text,
                    '',
                    DateTime.tryParse(start.text) ?? date.add(const Duration(hours: 9)),
                    DateTime.tryParse(end.text) ?? date.add(const Duration(hours: 10)),
                  ),
                );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // ------------------------------------------------
  // EDIT SCHEDULE UI (different design)
  // ------------------------------------------------
  Widget _buildEditDialog(BuildContext context, WidgetRef ref, TextEditingController title, TextEditingController start, TextEditingController end) {
    final schedule = existingSchedule!;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Edit Schedule", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: start,
              decoration: const InputDecoration(labelText: "Start"),
            ),
            TextField(
              controller: end,
              decoration: const InputDecoration(labelText: "End"),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(scheduleListProvider.notifier).removeSchedule(schedule);
                    Navigator.pop(context);
                  },
                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  child: const Text("Save"),
                  onPressed: () {
                    final notifier = ref.read(scheduleListProvider.notifier);

                    // Update by replacing the schedule
                    notifier.removeSchedule(schedule);
                    notifier.addSchedule(
                      homeController.createSchedule(
                        title.text.isEmpty ? "(No Title)" : title.text,
                        '',
                        DateTime.tryParse(start.text) ?? schedule.from,
                        DateTime.tryParse(end.text) ?? schedule.to,
                      ),
                    );

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
