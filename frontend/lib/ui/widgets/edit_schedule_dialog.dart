import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/schedule.dart';

class EditScheduleDialog extends ConsumerStatefulWidget {
  final Schedule schedule;

  const EditScheduleDialog({super.key, required this.schedule});

  @override
  ConsumerState<EditScheduleDialog> createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends ConsumerState<EditScheduleDialog> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.schedule.title);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Schedule"),
      content: TextField(
        controller: _titleController,
        decoration: const InputDecoration(labelText: "Title"),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Optional: delete schedule
            // ref.read(scheduleProvider.notifier).removeSchedule(widget.schedule);
            Navigator.of(context).pop();
          },
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              // ref
              //     .read(scheduleProvider.notifier)
              //     .updateSchedule(
              //       old: widget.schedule,
              //       newSchedule: Schedule(title: _titleController.text, date: widget.schedule.date),
              //     );
              Navigator.of(context).pop();
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
