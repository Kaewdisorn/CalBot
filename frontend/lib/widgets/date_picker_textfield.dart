import 'package:flutter/material.dart';

class DatePickerTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextEditingController? compareDateController;
  const DatePickerTextField({super.key, required this.controller, required this.label, this.compareDateController});

  @override
  State<DatePickerTextField> createState() => _DatePickerTextFieldState();
}

class _DatePickerTextFieldState extends State<DatePickerTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: widget.controller,
      onTap: () async {
        final ctx = context;

        final picked = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));

        if (!mounted || !ctx.mounted) return;

        if (picked != null) {
          final pickedStr = "${picked.year}-${picked.month}-${picked.day}";

          if (widget.compareDateController != null && widget.compareDateController!.text.isNotEmpty) {
            try {
              final compareDate = DateTime.parse(widget.compareDateController!.text);
              final pickedDate = DateTime.parse(pickedStr);

              if (pickedDate.isBefore(compareDate)) {
                showDialog(
                  context: ctx,
                  builder: (_) => AlertDialog(
                    title: const Text("Invalid Date"),
                    content: Text("End date cannot be before start date"),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
                  ),
                );
                return;
              }
            } catch (_) {}
          }

          widget.controller.text = pickedStr;
        }
      },
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.date_range, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
