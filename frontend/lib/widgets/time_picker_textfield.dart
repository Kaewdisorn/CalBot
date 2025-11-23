import 'package:flutter/material.dart';

import '../utils/datetime_format.dart';

/// Reusable TimePickerTextField
class TimePickerTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TimeOfDay initialTime;

  const TimePickerTextField({super.key, required this.controller, required this.label, required this.initialTime});

  @override
  State<TimePickerTextField> createState() => _TimePickerTextFieldState();
}

class _TimePickerTextFieldState extends State<TimePickerTextField> {
  /// Format TimeOfDay as HH:MM AM/PM

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: widget.controller,
      onTap: () async {
        final localContext = context; // capture context safely

        final time = await showTimePicker(context: localContext, initialTime: widget.initialTime);

        if (!mounted || !localContext.mounted) return;

        if (time != null) {
          widget.controller.text = formatTimeOfDayAMPM(time);
        }
      },
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
