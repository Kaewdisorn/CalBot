import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';

class AddScheduleDialog extends ConsumerStatefulWidget {
  final DateTime date;

  const AddScheduleDialog({super.key, required this.date});

  @override
  ConsumerState<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends ConsumerState<AddScheduleDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  Color _color = Colors.blue;
  bool _isDone = false;
  String? _recurrence;

  static const presetColors = [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.pink, Colors.teal, Colors.red];

  @override
  void initState() {
    super.initState();
    _startDate = widget.date;
    _endDate = widget.date.add(const Duration(hours: 1));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Schedule"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 12),

            // Start / End date
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Start"),
                    subtitle: Text("${_startDate!}"),
                    onTap: () async {
                      final date = await showDatePicker(context: context, initialDate: _startDate!, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (date != null) {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_startDate!));
                        if (time != null) {
                          setState(() {
                            _startDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            if (_endDate!.isBefore(_startDate!)) {
                              _endDate = _startDate!.add(const Duration(hours: 1));
                            }
                          });
                        }
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("End"),
                    subtitle: Text("${_endDate!}"),
                    onTap: () async {
                      final date = await showDatePicker(context: context, initialDate: _endDate!, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (date != null) {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_endDate!));
                        if (time != null) {
                          setState(() {
                            _endDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Color selection
            Wrap(
              spacing: 8,
              children: presetColors
                  .map(
                    (c) => GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(color: _color == c ? Colors.black : Colors.transparent, width: 2),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 12),

            // Recurrence
            DropdownButtonFormField<String>(
              value: _recurrence,
              decoration: const InputDecoration(labelText: "Recurrence"),
              items: const [
                DropdownMenuItem(value: null, child: Text("None")),
                DropdownMenuItem(value: "FREQ=DAILY;COUNT=10", child: Text("Daily")),
                DropdownMenuItem(value: "FREQ=WEEKLY;COUNT=10", child: Text("Weekly")),
                DropdownMenuItem(value: "FREQ=MONTHLY;COUNT=10", child: Text("Monthly")),
              ],
              onChanged: (value) => setState(() => _recurrence = value),
            ),

            const SizedBox(height: 12),

            // Done toggle
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Mark as Done"),
              value: _isDone,
              onChanged: (v) => setState(() => _isDone = v ?? false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty) return;

            final newSchedule = Schedule(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
              startDate: _startDate!,
              endDate: _endDate!,
              color: _color,
              isDone: _isDone,
              recurrenceRule: _recurrence,
            );

            ref.read(scheduleProvider.notifier).addSchedule(newSchedule);
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
