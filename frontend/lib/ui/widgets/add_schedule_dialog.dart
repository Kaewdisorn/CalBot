import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule.dart';

class AddScheduleDialog extends ConsumerStatefulWidget {
  final DateTime date;

  const AddScheduleDialog({super.key, required this.date});

  @override
  ConsumerState<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends ConsumerState<AddScheduleDialog> {
  final _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Schedule"),
      content: TextField(
        controller: _titleController,
        decoration: const InputDecoration(labelText: "Title"),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              ref.read(scheduleProvider.notifier).addSchedule(Schedule(title: _titleController.text, date: widget.date, id: '1'));
              Navigator.of(context).pop();
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
