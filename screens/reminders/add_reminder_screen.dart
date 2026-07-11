import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:mother_and_baby_smartcare/models/reminder_model.dart';
import 'package:mother_and_baby_smartcare/services/reminder_service.dart';
import 'package:mother_and_baby_smartcare/widgets/reminder_tile.dart';

class AddReminderScreen extends StatefulWidget {
  final ReminderModel? reminder;
  const AddReminderScreen({super.key, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final ReminderService _reminderService = ReminderService();

  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'Medicine';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _remindBefore = 10;
  String _repeat = 'None';
  int _color = 0;
  bool _saving = false;

  // NEW: holds the validation error for date/time, shown in red under the tiles
  String? _dateTimeError;

  static const Color primary = Color(0xFFE91E8C);
  static const Color background = Color(0xFFFFF0F5);
  static const Color textDark = Color(0xFF3D1A2E);
  static const Color errorColor = Color(0xFFD32F2F);

  final List<String> _types = [
    'Medicine',
    'Feeding',
    'Appointment',
    'Vaccination',
    'Checkup',
    'Other',
  ];
  final List<int> _remindOptions = [0, 5, 10, 15, 20, 30, 60];
  final List<String> _repeatOptions = ['None', 'Daily', 'Weekly', 'Monthly'];

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    if (r != null) {
      _titleController.text = r.title;
      _noteController.text = r.note;
      _type = r.type;
      _selectedDate = DateFormat('dd/MM/yyyy').parse(r.date);
      final parsedTime = DateFormat('hh:mm a').parse(r.time);
      _selectedTime = TimeOfDay.fromDateTime(parsedTime);
      _remindBefore = r.remindBefore;
      _repeat = r.repeat;
      _color = r.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        title: Text(
          _isEditing ? 'Update Reminder' : 'Add Reminder',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            TextFormField(
              controller: _titleController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _decoration('Title'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _noteController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _decoration('Note'),
              maxLines: 3,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Note is required' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _type,
              style: GoogleFonts.poppins(fontSize: 14, color: textDark),
              decoration: _decoration('Type'),
              items: _types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 14),
            _tile(
              label: 'Date',
              value: DateFormat('dd/MM/yyyy').format(_selectedDate),
              icon: Icons.calendar_month_rounded,
              onTap: _pickDate,
              hasError: _dateTimeError != null,
            ),
            const SizedBox(height: 10),
            _tile(
              label: 'Time',
              value: _selectedTime.format(context),
              icon: Icons.access_time_rounded,
              onTap: _pickTime,
              hasError: _dateTimeError != null,
            ),
            // NEW: red error message shown under Date/Time tiles
            if (_dateTimeError != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error_outline, color: errorColor, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _dateTimeError!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              initialValue: _remindBefore,
              style: GoogleFonts.poppins(fontSize: 14, color: textDark),
              decoration: _decoration('Remind me before'),
              items: _remindOptions
                  .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m == 0 ? 'At the time' : '$m minutes early')))
                  .toList(),
              onChanged: (v) => setState(() => _remindBefore = v ?? 0),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _repeat,
              style: GoogleFonts.poppins(fontSize: 14, color: textDark),
              decoration: _decoration('Repeat'),
              items: _repeatOptions
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _repeat = v ?? _repeat),
            ),
            const SizedBox(height: 22),
            Text('Color tag',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textDark)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: List.generate(reminderColors.length, (index) {
                final selected = _color == index;
                return GestureDetector(
                  onTap: () => setState(() => _color = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: selected ? 38 : 32,
                    height: selected ? 38 : 32,
                    decoration: BoxDecoration(
                      color: reminderColors[index],
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.black26, width: 2)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _isEditing ? 'Update Reminder' : 'Create Reminder',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool hasError = false, // NEW
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: hasError ? Border.all(color: errorColor, width: 1.2) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: hasError ? errorColor : textDark)),
                ],
              ),
            ),
            Icon(icon, color: hasError ? errorColor : primary, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _validateDateTime(); // NEW: re-check as soon as date changes
    }
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) {
      setState(() => _selectedTime = picked);
      _validateDateTime(); // NEW: re-check instead of silently adjusting
    }
  }

  DateTime get _combinedDateTime => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

  // NEW: returns true if valid (strictly in the future), false otherwise.
  // Also updates _dateTimeError so the UI shows the red message.
  bool _validateDateTime() {
    final now = DateTime.now();
    final combined = _combinedDateTime;

    // combined must be strictly after "now" (blocks past AND exact present minute)
    if (!combined.isAfter(now)) {
      setState(() {
        _dateTimeError =
            'Please select a future date and time. Past or current time is not allowed.';
      });
      return false;
    }

    setState(() => _dateTimeError = null);
    return true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // NEW: block save on past/current date-time with a red error
    if (!_validateDateTime()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_dateTimeError!),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final dateStr = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final timeStr = DateFormat('hh:mm a').format(_combinedDateTime);

    try {
      if (_isEditing) {
        final r = widget.reminder!;
        r.title = _titleController.text.trim();
        r.note = _noteController.text.trim();
        r.type = _type;
        r.date = dateStr;
        r.time = timeStr;
        r.remindBefore = _remindBefore;
        r.repeat = _repeat;
        r.color = _color;
        await _reminderService.updateReminder(r, _combinedDateTime);
      } else {
        await _reminderService.addReminder(
          title: _titleController.text.trim(),
          note: _noteController.text.trim(),
          type: _type,
          date: dateStr,
          time: timeStr,
          remindBefore: _remindBefore,
          repeat: _repeat,
          color: _color,
          reminderDateTime: _combinedDateTime,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save reminder: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
