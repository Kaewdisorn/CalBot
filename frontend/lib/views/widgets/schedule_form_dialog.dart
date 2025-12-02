import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/schedule_model.dart';

/// A professional, reusable dialog for adding/editing schedules.
/// Pass [existingSchedule] to edit mode, or leave null for add mode.
class ScheduleFormDialog extends StatefulWidget {
  final ScheduleModel? existingSchedule;
  final DateTime? initialDate;
  final Function(ScheduleModel) onSave;
  final VoidCallback? onDelete;

  const ScheduleFormDialog({super.key, this.existingSchedule, this.initialDate, required this.onSave, this.onDelete});

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _noteController;

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late bool _isAllDay;
  late Color _selectedColor;
  late bool _isDone;

  bool get isEditMode => widget.existingSchedule != null;

  // Color palette for schedule
  static const List<Color> colorPalette = [
    Color(0xFF42A5F5), // Blue
    Color(0xFF66BB6A), // Green
    Color(0xFFEF5350), // Red
    Color(0xFFAB47BC), // Purple
    Color(0xFFFF7043), // Orange
    Color(0xFF26A69A), // Teal
    Color(0xFFEC407A), // Pink
    Color(0xFF5C6BC0), // Indigo
  ];

  @override
  void initState() {
    super.initState();

    final schedule = widget.existingSchedule;
    final now = widget.initialDate ?? DateTime.now();

    _titleController = TextEditingController(text: schedule?.title ?? '');
    _locationController = TextEditingController(text: schedule?.location ?? '');
    _noteController = TextEditingController(text: schedule?.note ?? '');

    _startDate = schedule?.start ?? now;
    _startTime = TimeOfDay.fromDateTime(schedule?.start ?? now);
    _endDate = schedule?.end ?? now.add(const Duration(hours: 1));
    _endTime = TimeOfDay.fromDateTime(schedule?.end ?? now.add(const Duration(hours: 1)));
    _isAllDay = schedule?.isAllDay ?? false;
    _selectedColor = schedule != null ? Color(schedule.colorValue) : colorPalette[0];
    _isDone = schedule?.isDone ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 500 ? 500 : constraints.maxWidth;
          return Center(
            child: Container(
              width: maxWidth,
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeader(),

                  // Form Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Field
                          _buildTitleField(),
                          const SizedBox(height: 20),

                          // All Day Toggle
                          _buildAllDayToggle(),
                          const SizedBox(height: 16),

                          // Date & Time Pickers
                          _buildDateTimePickers(),
                          const SizedBox(height: 20),

                          // Location Field
                          _buildLocationField(),
                          const SizedBox(height: 20),

                          // Note Field
                          _buildNoteField(),
                          const SizedBox(height: 20),

                          // Color Picker
                          _buildColorPicker(),
                          const SizedBox(height: 20),

                          // Mark as Done Toggle
                          _buildMarkAsDoneToggle(),
                          const SizedBox(height: 24),

                          // Action Buttons
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        color: _selectedColor.withAlpha(25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(color: _selectedColor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEditMode ? 'Edit Schedule' : 'New Schedule',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Get.back(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      autofocus: !isEditMode,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'Enter schedule title',
        prefixIcon: const Icon(Icons.event_note_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _selectedColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildAllDayToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.sunny, color: _selectedColor, size: 22),
              const SizedBox(width: 12),
              const Text('All Day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          Switch(value: _isAllDay, onChanged: (val) => setState(() => _isAllDay = val), activeColor: _selectedColor),
        ],
      ),
    );
  }

  Widget _buildDateTimePickers() {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Column(
      children: [
        // Start Date/Time
        _buildDateTimeRow(
          label: 'Start',
          icon: Icons.schedule_outlined,
          date: _startDate,
          time: _startTime,
          dateStr: dateFormat.format(_startDate),
          timeStr: timeFormat.format(DateTime(2000, 1, 1, _startTime.hour, _startTime.minute)),
          onDateTap: () => _pickDate(isStart: true),
          onTimeTap: _isAllDay ? null : () => _pickTime(isStart: true),
        ),
        const SizedBox(height: 12),
        // End Date/Time
        _buildDateTimeRow(
          label: 'End',
          icon: Icons.schedule,
          date: _endDate,
          time: _endTime,
          dateStr: dateFormat.format(_endDate),
          timeStr: timeFormat.format(DateTime(2000, 1, 1, _endTime.hour, _endTime.minute)),
          onDateTap: () => _pickDate(isStart: false),
          onTimeTap: _isAllDay ? null : () => _pickTime(isStart: false),
        ),
      ],
    );
  }

  Widget _buildDateTimeRow({
    required String label,
    required IconData icon,
    required DateTime date,
    required TimeOfDay time,
    required String dateStr,
    required String timeStr,
    required VoidCallback onDateTap,
    VoidCallback? onTimeTap,
  }) {
    return Row(
      children: [
        Icon(icon, color: _selectedColor, size: 24),
        const SizedBox(width: 12),
        SizedBox(
          width: 45,
          child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ),
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: onDateTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateStr, style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        if (!_isAllDay) ...[
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: onTimeTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(timeStr, style: const TextStyle(fontSize: 14)),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationField() {
    return TextField(
      controller: _locationController,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Location',
        hintText: 'Add location (optional)',
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _selectedColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      style: const TextStyle(fontSize: 16),
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notes',
        hintText: 'Add notes (optional)',
        prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 48), child: Icon(Icons.notes_outlined)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _selectedColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.palette_outlined, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              'Color',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colorPalette.map((color) {
            final isSelected = _selectedColor.value == color.value;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                  boxShadow: [BoxShadow(color: isSelected ? color.withAlpha(150) : Colors.black12, blurRadius: isSelected ? 8 : 4, offset: const Offset(0, 2))],
                ),
                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMarkAsDoneToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isDone ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isDone ? Colors.green.shade300 : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(_isDone ? Icons.check_circle : Icons.check_circle_outline, color: _isDone ? Colors.green : Colors.grey.shade600, size: 22),
              const SizedBox(width: 12),
              Text(
                'Mark as Done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _isDone ? Colors.green.shade700 : Colors.black87),
              ),
            ],
          ),
          Checkbox(
            value: _isDone,
            onChanged: (val) => setState(() => _isDone = val ?? false),
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleSave,
            icon: Icon(isEditMode ? Icons.save : Icons.add, color: Colors.white),
            label: Text(
              isEditMode ? 'Save Changes' : 'Add Schedule',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
        ),

        // Delete Button (only in edit mode)
        if (isEditMode && widget.onDelete != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.back();
                widget.onDelete!();
              },
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: const Text('Delete Schedule', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: _selectedColor)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Auto-adjust end date if needed
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: _selectedColor)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final startDateTime = DateTime(_startDate.year, _startDate.month, _startDate.day, _isAllDay ? 0 : _startTime.hour, _isAllDay ? 0 : _startTime.minute);

    final endDateTime = DateTime(_endDate.year, _endDate.month, _endDate.day, _isAllDay ? 23 : _endTime.hour, _isAllDay ? 59 : _endTime.minute);

    if (endDateTime.isBefore(startDateTime)) {
      Get.snackbar(
        'Error',
        'End time cannot be before start time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final schedule = ScheduleModel(
      id: widget.existingSchedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      start: startDateTime,
      end: endDateTime,
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      isAllDay: _isAllDay,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      colorValue: _selectedColor.value,
      recurrenceRule: widget.existingSchedule?.recurrenceRule,
      exceptionDateList: widget.existingSchedule?.exceptionDateList,
      isDone: _isDone,
    );

    Get.back();
    widget.onSave(schedule);
  }
}
