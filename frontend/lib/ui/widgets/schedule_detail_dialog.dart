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
          Text(schedule.title),

          Row(
            children: [
              // Edit icon - uses theme primary color
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

              // Delete icon - uses theme error color
              IconButton(
                tooltip: "Delete",
                icon: Icon(Icons.delete, color: colors.error),
                onPressed: () {
                  // ref.read(scheduleProvider.notifier).removeSchedule(schedule);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),

      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Date: ${schedule.date.toLocal()}")]),

      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close"))],
    );
  }
}
