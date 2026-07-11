import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mother_and_baby_smartcare/models/reminder_model.dart';

const List<Color> reminderColors = [
  Color(0xFFE91E8C), // pink (matches Mother Health Tracker card)
  Color(0xFF3B82F6), // blue (matches Baby Health Tracker card)
  Color(0xFFF59E0B), // amber (matches Reminders card)
  Color(0xFF10B981), // green (matches Records & Graphs card)
];

const Map<String, IconData> reminderTypeIcons = {
  'Medicine': Icons.medication_rounded,
  'Feeding': Icons.baby_changing_station_rounded,
  'Appointment': Icons.event_rounded,
  'Vaccination': Icons.vaccines_rounded,
  'Checkup': Icons.health_and_safety_rounded,
  'Other': Icons.notifications_rounded,
};

class ReminderTile extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onTap;
  final VoidCallback onMorePressed;
  final ValueChanged<bool> onCompletedChanged;

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onMorePressed,
    required this.onCompletedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = reminderColors[reminder.color % reminderColors.length];

    return GestureDetector(
      onTap: onTap,
      onLongPress: onMorePressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.12), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                reminderTypeIcons[reminder.type] ?? Icons.notifications_rounded,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: reminder.isCompleted
                          ? Colors.grey
                          : const Color(0xFF3D1A2E),
                      decoration: reminder.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${reminder.type} • ${reminder.date} at ${reminder.time}"
                    "${reminder.repeat != 'None' ? ' • ${reminder.repeat}' : ''}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: reminder.isCompleted,
                  activeColor: color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  onChanged: (val) => onCompletedChanged(val ?? false),
                ),
                GestureDetector(
                  onTap: onMorePressed,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.more_vert_rounded,
                        size: 20, color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
