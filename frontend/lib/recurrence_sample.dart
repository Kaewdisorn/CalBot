// // schedule_with_recurrence_dialog.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';

// import '../controllers/home.dart';
// import '../providers/calendar.dart';
// import '../utils/datetime_format.dart';
// import '../widgets/date_picker_textfield.dart';
// import '../widgets/time_picker_textfield.dart';

// /// Recurrence model used by RecurrenceDialog to build/parse RRULE
// class RecurrenceModel {
//   String freq; // DAILY, WEEKLY, MONTHLY, YEARLY or NONE
//   int interval;
//   List<String> byDay; // ["MO","TU"...] for weekly/byday
//   int? byMonthDay; // day of month
//   int? bySetPos; // nth occurrence in month (e.g., 2nd -> 2, -1 for last)
//   String? byDayForSet; // e.g., "TU" when using bySetPos
//   String endType; // NONE, COUNT, UNTIL
//   int? count;
//   DateTime? until;

//   RecurrenceModel({
//     this.freq = 'NONE',
//     this.interval = 1,
//     List<String>? byDay,
//     this.byMonthDay,
//     this.bySetPos,
//     this.byDayForSet,
//     this.endType = 'NONE',
//     this.count,
//     this.until,
//   }) : byDay = byDay ?? [];

//   /// Build an RFC-style RRULE string (Syncfusion understands this)
//   String toRRuleString() {
//     if (freq == 'NONE') return '';
//     final parts = <String>['FREQ=$freq', 'INTERVAL=$interval'];

//     if (freq == 'WEEKLY' && byDay.isNotEmpty) {
//       parts.add('BYDAY=${byDay.join(',')}');
//     }

//     if (freq == 'MONTHLY') {
//       if (byMonthDay != null) {
//         parts.add('BYMONTHDAY=$byMonthDay');
//       } else if (bySetPos != null && byDayForSet != null) {
//         parts.add('BYDAY=$byDayForSet');
//         parts.add('BYSETPOS=${bySetPos}');
//       }
//     }

//     if (endType == 'COUNT' && count != null) {
//       parts.add('COUNT=${count!}');
//     } else if (endType == 'UNTIL' && until != null) {
//       // UNTIL must be in YYYYMMDD (or YYYYMMDDT000000Z) format — we'll use date-only local in YYYYMMDD
//       final y = until!.year.toString().padLeft(4, '0');
//       final m = until!.month.toString().padLeft(2, '0');
//       final d = until!.day.toString().padLeft(2, '0');
//       parts.add('UNTIL=${y}${m}${d}');
//     }

//     return parts.join(';');
//   }

//   /// Human readable summary
//   String toHumanReadable() {
//     if (freq == 'NONE') return 'No repeat';
//     final b = StringBuffer();
//     b.write('Every ');
//     if (interval > 1) b.write('$interval ');
//     switch (freq) {
//       case 'DAILY':
//         b.write('day${interval > 1 ? 's' : ''}');
//         break;
//       case 'WEEKLY':
//         b.write('week${interval > 1 ? 's' : ''}');
//         if (byDay.isNotEmpty) {
//           b.write(' on ${byDay.map(_weekdayName).join(', ')}');
//         }
//         break;
//       case 'MONTHLY':
//         b.write('month${interval > 1 ? 's' : ''}');
//         if (byMonthDay != null) {
//           b.write(' on day $byMonthDay');
//         } else if (bySetPos != null && byDayForSet != null) {
//           b.write(' on the ${_ordinal(bySetPos!)} ${_weekdayName(byDayForSet!)}');
//         }
//         break;
//       case 'YEARLY':
//         b.write('year${interval > 1 ? 's' : ''}');
//         break;
//       default:
//         b.write(freq.toLowerCase());
//     }

//     if (endType == 'COUNT' && count != null) {
//       b.write(', $count times');
//     } else if (endType == 'UNTIL' && until != null) {
//       b.write(', until ${formatYMD(until!)}');
//     }

//     return b.toString();
//   }

//   static String _weekdayName(String code) {
//     switch (code) {
//       case 'MO':
//         return 'Mon';
//       case 'TU':
//         return 'Tue';
//       case 'WE':
//         return 'Wed';
//       case 'TH':
//         return 'Thu';
//       case 'FR':
//         return 'Fri';
//       case 'SA':
//         return 'Sat';
//       case 'SU':
//         return 'Sun';
//     }
//     return code;
//   }

//   static String _ordinal(int n) {
//     if (n == -1) return 'last';
//     if (n == 1) return '1st';
//     if (n == 2) return '2nd';
//     if (n == 3) return '3rd';
//     return '${n}th';
//   }

//   /// Parse an RRULE-like string (basic support)
//   static RecurrenceModel fromRRule(String? rrule) {
//     final model = RecurrenceModel();
//     if (rrule == null || rrule.trim().isEmpty) return model;
//     final parts = rrule.split(';');
//     for (final p in parts) {
//       final kv = p.split('=');
//       if (kv.length != 2) continue;
//       final k = kv[0];
//       final v = kv[1];
//       switch (k) {
//         case 'FREQ':
//           model.freq = v;
//           break;
//         case 'INTERVAL':
//           model.interval = int.tryParse(v) ?? 1;
//           break;
//         case 'BYDAY':
//           model.byDay = v.split(',');
//           break;
//         case 'BYMONTHDAY':
//           model.byMonthDay = int.tryParse(v);
//           break;
//         case 'BYSETPOS':
//           model.bySetPos = int.tryParse(v);
//           break;
//         case 'COUNT':
//           model.endType = 'COUNT';
//           model.count = int.tryParse(v);
//           break;
//         case 'UNTIL':
//           model.endType = 'UNTIL';
//           // try parse YYYYMMDD
//           if (v.length >= 8) {
//             final y = int.tryParse(v.substring(0, 4));
//             final m = int.tryParse(v.substring(4, 6));
//             final d = int.tryParse(v.substring(6, 8));
//             if (y != null && m != null && d != null) {
//               model.until = DateTime(y, m, d);
//             }
//           }
//           break;
//       }
//     }

//     // If BYDAY present and BYSETPOS present, map byDayForSet
//     if (model.byDay.isNotEmpty && model.bySetPos != null && model.byDay.length == 1) {
//       model.byDayForSet = model.byDay.first;
//       model.byDay = []; // clear direct list since using setpos variant
//     }

//     return model;
//   }
// }

// /// Recurrence editor dialog - returns RecurrenceModel or null when canceled
// class RecurrenceDialog extends StatefulWidget {
//   final RecurrenceModel model;
//   const RecurrenceDialog({super.key, required this.model});

//   @override
//   State<RecurrenceDialog> createState() => _RecurrenceDialogState();
// }

// class _RecurrenceDialogState extends State<RecurrenceDialog> {
//   late String freq;
//   late int interval;
//   late List<String> byDay;
//   int? byMonthDay;
//   int? bySetPos;
//   String? byDayForSet;
//   late String endType;
//   int? count;
//   DateTime? until;

//   @override
//   void initState() {
//     super.initState();
//     final m = widget.model;
//     freq = m.freq;
//     interval = m.interval;
//     byDay = List.from(m.byDay);
//     byMonthDay = m.byMonthDay;
//     bySetPos = m.bySetPos;
//     byDayForSet = m.byDayForSet;
//     endType = m.endType;
//     count = m.count;
//     until = m.until;
//   }

//   void toggleWeekday(String code) {
//     setState(() {
//       if (byDay.contains(code)) {
//         byDay.remove(code);
//       } else {
//         byDay.add(code);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final model = RecurrenceModel(
//       freq: freq,
//       interval: interval,
//       byDay: byDay,
//       byMonthDay: byMonthDay,
//       bySetPos: bySetPos,
//       byDayForSet: byDayForSet,
//       endType: endType,
//       count: count,
//       until: until,
//     );

//     return AlertDialog(
//       title: const Text('Recurrence'),
//       content: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Frequency dropdown
//             Row(
//               children: [
//                 const Text('Repeat'),
//                 const SizedBox(width: 12),
//                 DropdownButton<String>(
//                   value: freq,
//                   items: const [
//                     DropdownMenuItem(value: 'NONE', child: Text('Does not repeat')),
//                     DropdownMenuItem(value: 'DAILY', child: Text('Daily')),
//                     DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly')),
//                     DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
//                     DropdownMenuItem(value: 'YEARLY', child: Text('Yearly')),
//                   ],
//                   onChanged: (v) => setState(() {
//                     freq = v ?? 'NONE';
//                     // reset some fields when frequency changes
//                     byDay = [];
//                     byMonthDay = null;
//                     bySetPos = null;
//                     byDayForSet = null;
//                   }),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             // Interval
//             Row(
//               children: [
//                 const Text('Repeat every'),
//                 const SizedBox(width: 12),
//                 SizedBox(
//                   width: 80,
//                   child: TextFormField(
//                     initialValue: interval.toString(),
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(isDense: true),
//                     onChanged: (v) {
//                       final n = int.tryParse(v) ?? 1;
//                       setState(() => interval = n < 1 ? 1 : n);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   freq == 'DAILY'
//                       ? 'day(s)'
//                       : freq == 'WEEKLY'
//                       ? 'week(s)'
//                       : freq == 'MONTHLY'
//                       ? 'month(s)'
//                       : freq == 'YEARLY'
//                       ? 'year(s)'
//                       : '',
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // Weekly options: day pickers
//             if (freq == 'WEEKLY') ...[
//               const Text('Repeat on'),
//               const SizedBox(height: 8),
//               Wrap(
//                 spacing: 6,
//                 children: [
//                   _weekdayChip('MO', byDay.contains('MO'), () => toggleWeekday('MO')),
//                   _weekdayChip('TU', byDay.contains('TU'), () => toggleWeekday('TU')),
//                   _weekdayChip('WE', byDay.contains('WE'), () => toggleWeekday('WE')),
//                   _weekdayChip('TH', byDay.contains('TH'), () => toggleWeekday('TH')),
//                   _weekdayChip('FR', byDay.contains('FR'), () => toggleWeekday('FR')),
//                   _weekdayChip('SA', byDay.contains('SA'), () => toggleWeekday('SA')),
//                   _weekdayChip('SU', byDay.contains('SU'), () => toggleWeekday('SU')),
//                 ],
//               ),
//               const SizedBox(height: 12),
//             ],

//             // Monthly options
//             if (freq == 'MONTHLY') ...[
//               const Text('Monthly options'),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Radio<bool>(
//                     value: true,
//                     groupValue: byMonthDay != null,
//                     onChanged: (_) => setState(() {
//                       byMonthDay = byMonthDay ?? 1;
//                       bySetPos = null;
//                       byDayForSet = null;
//                     }),
//                   ),
//                   const SizedBox(width: 4),
//                   const Text('Day of month'),
//                   const SizedBox(width: 12),
//                   SizedBox(
//                     width: 80,
//                     child: TextFormField(
//                       initialValue: byMonthDay?.toString() ?? '',
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(isDense: true),
//                       onChanged: (v) => setState(() {
//                         final n = int.tryParse(v);
//                         byMonthDay = n;
//                       }),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Radio<bool>(
//                     value: true,
//                     groupValue: bySetPos != null,
//                     onChanged: (_) => setState(() {
//                       bySetPos = bySetPos ?? 1;
//                       byDayForSet = byDayForSet ?? 'MO';
//                       byMonthDay = null;
//                     }),
//                   ),
//                   const SizedBox(width: 4),
//                   const Text('Nth weekday'),
//                   const SizedBox(width: 12),
//                   SizedBox(
//                     width: 80,
//                     child: TextFormField(
//                       initialValue: bySetPos?.toString() ?? '',
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(isDense: true),
//                       onChanged: (v) => setState(() {
//                         final n = int.tryParse(v) ?? 0;
//                         if (n == -1 || (n >= 1 && n <= 5)) {
//                           bySetPos = n;
//                         } else {
//                           // ignore bad input
//                         }
//                       }),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   DropdownButton<String>(
//                     value: byDayForSet ?? 'MO',
//                     items: const [
//                       DropdownMenuItem(value: 'MO', child: Text('Mon')),
//                       DropdownMenuItem(value: 'TU', child: Text('Tue')),
//                       DropdownMenuItem(value: 'WE', child: Text('Wed')),
//                       DropdownMenuItem(value: 'TH', child: Text('Thu')),
//                       DropdownMenuItem(value: 'FR', child: Text('Fri')),
//                       DropdownMenuItem(value: 'SA', child: Text('Sat')),
//                       DropdownMenuItem(value: 'SU', child: Text('Sun')),
//                     ],
//                     onChanged: (v) => setState(() => byDayForSet = v),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//             ],

//             // End options
//             const Text('End'),
//             const SizedBox(height: 8),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 RadioListTile<String>(title: const Text('Never'), value: 'NONE', groupValue: endType, onChanged: (v) => setState(() => endType = v ?? 'NONE')),
//                 RadioListTile<String>(
//                   title: Row(
//                     children: [
//                       const Text('After'),
//                       const SizedBox(width: 8),
//                       SizedBox(
//                         width: 80,
//                         child: TextFormField(
//                           initialValue: count?.toString() ?? '',
//                           keyboardType: TextInputType.number,
//                           decoration: const InputDecoration(isDense: true),
//                           onChanged: (v) => setState(() {
//                             final n = int.tryParse(v);
//                             count = n;
//                           }),
//                           onTap: () => setState(() => endType = 'COUNT'),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       const Text('occurrences'),
//                     ],
//                   ),
//                   value: 'COUNT',
//                   groupValue: endType,
//                   onChanged: (v) => setState(() => endType = v ?? 'COUNT'),
//                 ),
//                 RadioListTile<String>(
//                   title: Row(
//                     children: [
//                       const Text('On date'),
//                       const SizedBox(width: 8),
//                       TextButton(
//                         onPressed: () async {
//                           final chosen = await showDatePicker(
//                             context: context,
//                             initialDate: until ?? DateTime.now(),
//                             firstDate: DateTime(1900),
//                             lastDate: DateTime(2100),
//                           );
//                           if (chosen != null) setState(() => until = chosen);
//                           setState(() => endType = 'UNTIL');
//                         },
//                         child: Text(until == null ? 'Choose date' : formatYMD(until!)),
//                       ),
//                     ],
//                   ),
//                   value: 'UNTIL',
//                   groupValue: endType,
//                   onChanged: (v) => setState(() => endType = v ?? 'UNTIL'),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // Preview
//             Text('Preview', style: Theme.of(context).textTheme.subtitle1),
//             const SizedBox(height: 8),
//             Text(model.toHumanReadable()),
//             const SizedBox(height: 6),
//             Text('RRULE: ${model.toRRuleString()}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
//         TextButton(
//           onPressed: () {
//             final outModel = RecurrenceModel(
//               freq: freq,
//               interval: interval,
//               byDay: List.from(byDay),
//               byMonthDay: byMonthDay,
//               bySetPos: bySetPos,
//               byDayForSet: byDayForSet,
//               endType: endType,
//               count: count,
//               until: until,
//             );
//             Navigator.pop(context, outModel);
//           },
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }

//   Widget _weekdayChip(String code, bool selected, VoidCallback onTap) {
//     return ChoiceChip(label: Text(RecurrenceModel._weekdayName(code)), selected: selected, onSelected: (_) => onTap());
//   }
// }

// /// Main ScheduleDialog with Recurrence support (opens RecurrenceDialog)
// class ScheduleDialogWithRecurrence extends ConsumerStatefulWidget {
//   final DateTime date;
//   final HomeController homeController;
//   final Appointment? existingAppointment;

//   const ScheduleDialogWithRecurrence({super.key, required this.date, required this.homeController, this.existingAppointment});

//   @override
//   ConsumerState<ScheduleDialogWithRecurrence> createState() => _ScheduleDialogWithRecurrenceState();
// }

// class _ScheduleDialogWithRecurrenceState extends ConsumerState<ScheduleDialogWithRecurrence> {
//   late final TextEditingController titleController;
//   late final TextEditingController locationController;
//   late final TextEditingController startDateController;
//   late final TextEditingController startTimeController;
//   late final TextEditingController endDateController;
//   late final TextEditingController endTimeController;
//   late final TextEditingController descriptionController;

//   bool allDay = false;
//   bool isDone = false;
//   late Color selectedColor;
//   final List<Color> paletteColors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink];
//   String? _prevStartTimeText;
//   String? _prevEndTimeText;

//   // Recurrence model for this appointment (editable via separate dialog)
//   late RecurrenceModel recurrenceModel;

//   @override
//   void initState() {
//     super.initState();
//     final a = widget.existingAppointment;

//     titleController = TextEditingController(text: a?.subject ?? "");
//     locationController = TextEditingController(text: a?.location ?? "");
//     descriptionController = TextEditingController(text: a != null ? jsonDecode(a.notes ?? '{}')['description'] ?? '' : '');
//     selectedColor = a?.color ?? paletteColors.first;

//     final start = a?.startTime ?? widget.date;
//     final end = a?.endTime ?? widget.date.add(const Duration(hours: 1));

//     startDateController = TextEditingController(text: formatYMD(start));
//     endDateController = TextEditingController(text: formatYMD(end));
//     startTimeController = TextEditingController(text: formatTimeOfDayAMPM(TimeOfDay.fromDateTime(start)));
//     endTimeController = TextEditingController(text: formatTimeOfDayAMPM(TimeOfDay.fromDateTime(end)));

//     isDone = a != null ? jsonDecode(a.notes ?? '{}')['isDone'] ?? false : false;

//     recurrenceModel = RecurrenceModel.fromRRule((a?.recurrenceRule) ?? '');

//     // Auto-check allDay if full day
//     if (start.hour == 0 && start.minute == 0 && end.hour == 23 && end.minute == 59) {
//       allDay = true;
//       _prevStartTimeText = startTimeController.text;
//       _prevEndTimeText = endTimeController.text;
//     }

//     startDateController.addListener(_onStartDateChanged);
//   }

//   void _onStartDateChanged() {
//     if (allDay) {
//       endDateController.text = startDateController.text;
//     }
//   }

//   @override
//   void dispose() {
//     startDateController.removeListener(_onStartDateChanged);
//     titleController.dispose();
//     locationController.dispose();
//     startDateController.dispose();
//     startTimeController.dispose();
//     endDateController.dispose();
//     endTimeController.dispose();
//     descriptionController.dispose();
//     super.dispose();
//   }

//   TimeOfDay? parseTimeOfDay(String timeStr) {
//     try {
//       timeStr = timeStr.trim().toLowerCase();
//       final isPM = timeStr.contains('pm');
//       final isAM = timeStr.contains('am');
//       timeStr = timeStr.replaceAll(RegExp(r'\s*(am|pm)'), '');

//       int hour = 0, minute = 0;
//       final parts = timeStr.split(':');
//       if (parts.length == 2) {
//         hour = int.parse(parts[0]);
//         minute = int.parse(parts[1]);
//       } else if (parts.length == 1) {
//         hour = int.parse(parts[0]);
//       } else {
//         return null;
//       }

//       if (isPM && hour != 12) hour += 12;
//       if (isAM && hour == 12) hour = 0;

//       return TimeOfDay(hour: hour, minute: minute);
//     } catch (_) {
//       return null;
//     }
//   }

//   void pickCustomColor() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Pick Custom Color"),
//         content: SingleChildScrollView(
//           child: ColorPicker(
//             pickerColor: selectedColor,
//             onColorChanged: (color) => setState(() => selectedColor = color),
//             labelTypes: const [],
//             enableAlpha: false,
//             pickerAreaHeightPercent: 0.8,
//           ),
//         ),
//         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))],
//       ),
//     );
//   }

//   Future<void> openRecurrenceEditor() async {
//     final result = await showDialog<RecurrenceModel>(
//       context: context,
//       builder: (_) => RecurrenceDialog(model: recurrenceModel),
//     );
//     if (result != null) {
//       setState(() => recurrenceModel = result);
//     }
//   }

//   void showErrorDialog(String message) {
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Error"),
//         content: Text(message),
//         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.existingAppointment != null;
//     final dialogWidth = MediaQuery.of(context).size.width * 0.8;
//     final dialogHeight = MediaQuery.of(context).size.height * 0.7;

//     return AlertDialog(
//       title: Text(isEditing ? 'Edit Schedule' : 'Add Schedule'),
//       content: SizedBox(
//         width: dialogWidth,
//         height: dialogHeight,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // Title & Location
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: titleController,
//                       decoration: InputDecoration(
//                         labelText: 'Title',
//                         prefixIcon: const Icon(Icons.title),
//                         filled: true,
//                         fillColor: Colors.grey.shade100,
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//                       ),
//                       onChanged: (_) => setState(() {}),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: TextField(
//                       controller: locationController,
//                       decoration: InputDecoration(
//                         labelText: 'Location',
//                         prefixIcon: const Icon(Icons.location_on),
//                         filled: true,
//                         fillColor: Colors.grey.shade100,
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Dates & Times
//               Row(
//                 children: [
//                   Expanded(
//                     child: DatePickerTextField(controller: startDateController, label: 'Start Date', initialDate: widget.date),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TimePickerTextField(
//                       controller: startTimeController,
//                       label: 'Start Time',
//                       initialTime: const TimeOfDay(hour: 0, minute: 1),
//                       enabled: !allDay,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: DatePickerTextField(controller: endDateController, label: 'End Date', initialDate: widget.date),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TimePickerTextField(
//                       controller: endTimeController,
//                       label: 'End Time',
//                       initialTime: const TimeOfDay(hour: 23, minute: 59),
//                       enabled: !allDay,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // All Day & Done
//               Row(
//                 children: [
//                   Checkbox(
//                     value: allDay,
//                     onChanged: (v) {
//                       setState(() {
//                         final nv = v ?? false;
//                         if (nv && !allDay) {
//                           _prevStartTimeText = startTimeController.text;
//                           _prevEndTimeText = endTimeController.text;
//                           startTimeController.text = '00:00';
//                           endTimeController.text = '23:59';
//                           endDateController.text = startDateController.text;
//                         } else if (!nv && allDay) {
//                           if (_prevStartTimeText != null) startTimeController.text = _prevStartTimeText!;
//                           if (_prevEndTimeText != null) endTimeController.text = _prevEndTimeText!;
//                         }
//                         allDay = nv;
//                       });
//                     },
//                   ),
//                   const Text('All Day'),
//                   const SizedBox(width: 16),
//                   Checkbox(value: isDone, onChanged: (v) => setState(() => isDone = v ?? false)),
//                   const Text('Mark as Done'),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Description
//               TextField(
//                 controller: descriptionController,
//                 maxLines: 4,
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   prefix: Padding(padding: const EdgeInsets.only(top: 12, right: 8), child: const Icon(Icons.description)),
//                   alignLabelWithHint: true,
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // Color palette + custom
//               Row(
//                 children: [
//                   ...paletteColors.map(
//                     (c) => GestureDetector(
//                       onTap: () => setState(() => selectedColor = c),
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         width: 30,
//                         height: 30,
//                         decoration: BoxDecoration(
//                           color: c,
//                           shape: BoxShape.circle,
//                           border: selectedColor == c ? Border.all(width: 3, color: Colors.black) : null,
//                         ),
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: pickCustomColor,
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       width: 30,
//                       height: 30,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: const Icon(Icons.add, size: 20),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Recurrence summary + Edit button
//               Row(
//                 children: [
//                   Expanded(child: Text('Repeat: ${recurrenceModel.toHumanReadable()}')),
//                   TextButton(onPressed: openRecurrenceEditor, child: const Text('Edit')),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // Live preview with color and line-through if done
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: selectedColor,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.black12),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 16,
//                       height: 16,
//                       decoration: BoxDecoration(color: Colors.white.withAlpha((0.2 * 255).round()), shape: BoxShape.circle),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         titleController.text.isEmpty ? 'Sample Title' : titleController.text,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             if (isEditing)
//               TextButton(
//                 onPressed: () {
//                   ref.read(scheduleListProvider.notifier).removeAppointment(widget.existingAppointment!);
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Delete', style: TextStyle(color: Colors.red)),
//               ),
//             const SizedBox(width: 8),
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//             const SizedBox(width: 8),
//             FilledButton(onPressed: saveAppointment, child: Text(isEditing ? 'Save' : 'Add')),
//           ],
//         ),
//       ],
//     );
//   }

//   void saveAppointment() {
//     final notifier = ref.read(scheduleListProvider.notifier);

//     DateTime? startDateParsed;
//     DateTime? endDateParsed;
//     try {
//       startDateParsed = DateTime.parse(startDateController.text);
//       endDateParsed = DateTime.parse(endDateController.text);
//     } catch (_) {
//       showErrorDialog('Invalid date format.');
//       return;
//     }

//     final startTOD = parseTimeOfDay(startTimeController.text);
//     final endTOD = parseTimeOfDay(endTimeController.text);
//     if (startTOD == null || endTOD == null) {
//       showErrorDialog('Invalid time format.');
//       return;
//     }

//     final startDateTime = DateTime(startDateParsed.year, startDateParsed.month, startDateParsed.day, startTOD.hour, startTOD.minute);
//     final endDateTime = DateTime(endDateParsed.year, endDateParsed.month, endDateParsed.day, endTOD.hour, endTOD.minute);

//     if (endDateTime.isBefore(startDateTime)) {
//       showErrorDialog('End date/time must be after start date/time.');
//       return;
//     }

//     if (widget.existingAppointment != null) {
//       notifier.removeAppointment(widget.existingAppointment!);
//     }

//     // build notes JSON
//     final notesMap = {'description': descriptionController.text, 'isDone': isDone};

//     final appt = Appointment(
//       startTime: startDateTime,
//       endTime: endDateTime,
//       subject: titleController.text.isEmpty ? '(No Title)' : titleController.text,
//       location: locationController.text,
//       color: selectedColor,
//       isAllDay: allDay,
//       notes: jsonEncode(notesMap),
//       recurrenceRule: recurrenceModel.toRRuleString(),
//     );

//     notifier.addAppointment(appt);

//     if (mounted) Navigator.pop(context);
//   }
// }
