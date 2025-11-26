import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/schedule.dart';
import 'edit_schedule_dialog.dart';

class ScheduleDetailDialog extends ConsumerWidget {
  final Schedule schedule;

  const ScheduleDetailDialog({super.key, required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(schedule.title, style: TextStyle(decoration: schedule.isDone ? TextDecoration.lineThrough : null)),
          ),
          Row(
            children: [
              IconButton(
                tooltip: "Edit",
                icon: Icon(Icons.edit, color: colors.primary),
                onPressed: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (_) => EditScheduleDialog(schedule: schedule),
                  );
                },
              ),
              IconButton(
                tooltip: "Delete",
                icon: Icon(Icons.delete, color: colors.error),
                onPressed: () {
                  // TODO: call provider to remove
                  Navigator.of(context).pop();
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
          Text("Start: ${schedule.startDate.toLocal()}", style: const TextStyle(fontWeight: FontWeight.w500)),
          Text("End: ${schedule.endDate.toLocal()}", style: const TextStyle(fontWeight: FontWeight.w500)),
          if (schedule.description != null) ...[
            const SizedBox(height: 8),
            Text("Description: ${schedule.description}", style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 8),
          Text(
            "Status: ${schedule.isDone ? "Done ✅" : "Pending"}",
            style: TextStyle(color: schedule.isDone ? Colors.green : Colors.orange, fontWeight: FontWeight.w600),
          ),
          if (schedule.recurrenceRule != null) ...[const SizedBox(height: 8), Text("Recurrence: ${schedule.recurrenceRule}")],
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close"))],
    );
  }
}
