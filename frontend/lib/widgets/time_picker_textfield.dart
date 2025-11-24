import 'package:flutter/material.dart';

class TimePickerTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TimeOfDay initialTime;

  const TimePickerTextField({super.key, required this.controller, required this.label, required this.initialTime});

  @override
  State<TimePickerTextField> createState() => _TimePickerTextFieldState();
}

class _TimePickerTextFieldState extends State<TimePickerTextField> {
  // Convert TimeOfDay → HH:MM AM/PM
  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $suffix";
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isEmpty) {
      widget.controller.text = formatTime(widget.initialTime);
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context, // THIS IS SAFE
      initialTime: widget.initialTime,
      builder: (context, child) {
        return MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), child: child!);
      },
    );

    if (!mounted) return; // SAFE AGAINST ASYNC BUILD CONTEXT ERROR

    if (picked != null) {
      widget.controller.text = formatTime(picked);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.access_time),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      onTap: pickTime,
    );
  }
}
