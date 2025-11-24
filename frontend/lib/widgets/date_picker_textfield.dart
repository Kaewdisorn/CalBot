import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class DatePickerTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final DateTime initialDate;

  const DatePickerTextField({super.key, required this.controller, required this.label, required this.initialDate});

  @override
  State<DatePickerTextField> createState() => _DatePickerTextFieldState();
}

class _DatePickerTextFieldState extends State<DatePickerTextField> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();

    // Set default formatted date if empty
    if (widget.controller.text.isEmpty) {
      widget.controller.text = formatter.format(widget.initialDate);
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context, // SAFE USAGE
      initialDate: widget.initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (!mounted) return; // FIX async gap warning

    if (picked != null) {
      widget.controller.text = formatter.format(picked);

      // Refresh widget if needed visually
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
        prefixIcon: const Icon(Icons.calendar_today),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      onTap: pickDate,
    );
  }
}
