import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/schedule.dart';
import 'edit_schedule_dialog.dart';

class ScheduleDetailDialog extends ConsumerWidget {
  final Schedule schedule;

  const ScheduleDetailDialog({super.key, required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(schedule.title),
          Row(
            children: [
              // Edit icon
              IconButton(
                tooltip: "Edit",
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.of(context).pop(); // close detail popup
                  showDialog(
                    context: context,
                    builder: (_) => EditScheduleDialog(schedule: schedule),
                  );
                },
              ),
              // Delete icon
              IconButton(
                tooltip: "Delete",
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  //ref.read(scheduleProvider.notifier).removeSchedule(schedule);
                  Navigator.of(context).pop(); // close detail popup
                },
              ),
            ],
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Date: ${schedule.date.toLocal()}"),
          // Add more details here if needed
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close"))],
    );
  }
}
