import 'package:flutter/material.dart';

class RecurrenceDialog extends StatefulWidget {
  final Map<String, dynamic>? initialRecurrence;
  final Function(Map<String, dynamic> recurrence) onSave;

  const RecurrenceDialog({super.key, this.initialRecurrence, required this.onSave});

  @override
  State<RecurrenceDialog> createState() => _RecurrenceDialogState();
}

class _RecurrenceDialogState extends State<RecurrenceDialog> {
  late String selectedType;
  late int interval;
  late List<int> selectedWeekdays; // 1=Mon ... 7=Sun
  int? monthlyDay;
  late String monthlyOption; // DayOfMonth / WeekdayOfMonth

  @override
  void initState() {
    super.initState();
    final data = widget.initialRecurrence ?? {};
    selectedType = data['type'] ?? 'Daily';
    interval = data['interval'] ?? 1;
    selectedWeekdays = data['weekdays']?.cast<int>() ?? [];
    monthlyDay = data['monthlyDay'] ?? DateTime.now().day;
    monthlyOption = data['monthlyOption'] ?? 'DayOfMonth';
  }

  String getSummary() {
    switch (selectedType) {
      case 'Daily':
        return "Repeats every $interval day${interval > 1 ? 's' : ''}";
      case 'Weekly':
        if (selectedWeekdays.isEmpty) return "Repeats every $interval week(s)";
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final days = selectedWeekdays.map((d) => weekdays[d - 1]).join(", ");
        return "Repeats every $interval week${interval > 1 ? 's' : ''} on $days";
      case 'Monthly':
        if (monthlyOption == 'DayOfMonth') return "Repeats every $interval month(s) on day $monthlyDay";
        return "Repeats every $interval month(s) on $monthlyOption";
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget intervalSlider() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Interval: $interval ${selectedType.toLowerCase()}${interval > 1 ? 's' : ''}"),
          Slider(
            min: 1,
            max: 30,
            divisions: 29,
            value: interval.toDouble(),
            label: interval.toString(),
            onChanged: (val) => setState(() => interval = val.toInt()),
          ),
        ],
      );
    }

    Widget weeklySelector() {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return Wrap(
        spacing: 4,
        children: List.generate(7, (i) {
          final day = i + 1;
          final selected = selectedWeekdays.contains(day);
          return FilterChip(
            label: Text(weekdays[i]),
            selected: selected,
            onSelected: (v) {
              setState(() {
                if (v)
                  selectedWeekdays.add(day);
                else
                  selectedWeekdays.remove(day);
              });
            },
          );
        }),
      );
    }

    Widget monthlySelector() {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("Day of month"),
                  value: 'DayOfMonth',
                  groupValue: monthlyOption,
                  onChanged: (v) => setState(() => monthlyOption = v!),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("Weekday of month"),
                  value: 'WeekdayOfMonth',
                  groupValue: monthlyOption,
                  onChanged: (v) => setState(() => monthlyOption = v!),
                ),
              ),
            ],
          ),
          if (monthlyOption == 'DayOfMonth')
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Day"),
              controller: TextEditingController(text: monthlyDay.toString()),
              onChanged: (v) => monthlyDay = int.tryParse(v),
            ),
          if (monthlyOption == 'WeekdayOfMonth') const Text("TODO: Select week & weekday (e.g., 2nd Tuesday)"),
        ],
      );
    }

    return AlertDialog(
      title: const Text("Set Recurrence"),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Type
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  items: ['Daily', 'Weekly', 'Monthly'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Interval
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(padding: const EdgeInsets.all(8), child: intervalSlider()),
            ),
            const SizedBox(height: 8),
            if (selectedType == 'Weekly')
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(padding: const EdgeInsets.all(8), child: weeklySelector()),
              ),
            if (selectedType == 'Monthly')
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(padding: const EdgeInsets.all(8), child: monthlySelector()),
              ),
            const SizedBox(height: 12),
            Text(getSummary(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onSave({
              'type': selectedType,
              'interval': interval,
              if (selectedType == 'Weekly') 'weekdays': selectedWeekdays,
              if (selectedType == 'Monthly') 'monthlyDay': monthlyDay,
              if (selectedType == 'Monthly') 'monthlyOption': monthlyOption,
            });
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
      ],
    );
  }
}
