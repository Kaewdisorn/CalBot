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
    final titleController = TextEditingController(text: existingSchedule?.eventName ?? '');
    final startController = TextEditingController(text: (existingSchedule?.from ?? date.add(const Duration(hours: 9))).toString());
    final endController = TextEditingController(text: (existingSchedule?.to ?? date.add(const Duration(hours: 10))).toString());

    return AlertDialog(
      title: Text(existingSchedule != null ? 'Edit Schedule' : 'Add Schedule'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextFormField(
            controller: startController,
            decoration: const InputDecoration(labelText: 'Start Time'),
          ),
          TextFormField(
            controller: endController,
            decoration: const InputDecoration(labelText: 'End Time'),
          ),
        ],
      ),
      actions: [
        if (existingSchedule != null)
          TextButton(
            onPressed: () {
              ref.read(scheduleListProvider.notifier).removeSchedule(existingSchedule!);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final startTime = DateTime.tryParse(startController.text) ?? date.add(const Duration(hours: 9));
            final endTime = DateTime.tryParse(endController.text) ?? date.add(const Duration(hours: 10));

            final newSchedule = homeController.createSchedule(titleController.text.isEmpty ? '(No Title)' : titleController.text, startTime, endTime);

            final notifier = ref.read(scheduleListProvider.notifier);

            if (existingSchedule != null) {
              notifier.removeSchedule(existingSchedule!);
              notifier.addSchedule(newSchedule);
            } else {
              notifier.addSchedule(newSchedule);
            }

            Navigator.pop(context);
          },
          child: Text(existingSchedule != null ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
