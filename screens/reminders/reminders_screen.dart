import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mother_and_baby_smartcare/models/reminder_model.dart';
import 'package:mother_and_baby_smartcare/screens/reminders/add_reminder_screen.dart';
import 'package:mother_and_baby_smartcare/services/reminder_service.dart';

import 'package:mother_and_baby_smartcare/services/alarm_permissions.dart';
import 'package:mother_and_baby_smartcare/widgets/reminder_tile.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ReminderService _reminderService = ReminderService();

  static const Color primary = Color(0xFFE91E8C);
  static const Color background = Color(0xFFFFF0F5);
  static const Color textDark = Color(0xFF3D1A2E);

  @override
  void initState() {
    super.initState();
    // Make sure notification/exact-alarm permissions are granted the
    // first time the user opens this screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AlarmPermissions.requestAll();
    });
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
          'Reminders',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        actions: const [],
      ),
      body: StreamBuilder<List<ReminderModel>>(
        stream: _reminderService.streamReminders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong: ${snapshot.error}',
                style: GoogleFonts.poppins(),
              ),
            );
          }
          final reminders = snapshot.data ?? [];
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_rounded,
                      size: 56, color: Colors.pink.shade100),
                  const SizedBox(height: 12),
                  Text(
                    'No reminders yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Dismissible(
                key: Key(reminder.id!),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 22),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                confirmDismiss: (_) => _confirmDelete(reminder),
                child: ReminderTile(
                  reminder: reminder,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddReminderScreen(reminder: reminder),
                    ),
                  ),
                  onMorePressed: () => _showActionSheet(reminder),
                  onCompletedChanged: (val) =>
                      _reminderService.markCompleted(reminder, val),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddReminderScreen()),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Reminder',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showActionSheet(ReminderModel reminder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 100,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  reminder.title,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textDark),
                ),
                const SizedBox(height: 16),
                _actionButton(
                  label: 'Update Reminder',
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddReminderScreen(reminder: reminder),
                      ),
                    );
                  },
                ),
                if (!reminder.isCompleted)
                  _actionButton(
                    label: 'Mark as Completed',
                    icon: Icons.check_circle_rounded,
                    color: primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      _reminderService.markCompleted(reminder, true);
                    },
                  ),
                _actionButton(
                  label: 'Delete Reminder',
                  icon: Icons.delete_rounded,
                  color: Colors.red.shade400,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _confirmDelete(reminder);
                  },
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Close',
                      style: GoogleFonts.poppins(color: Colors.grey.shade500)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13),
            side: BorderSide(color: color.withValues(alpha: 0.35)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: Icon(icon, color: color, size: 20),
          label: Text(label,
              style: GoogleFonts.poppins(
                  color: color, fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(ReminderModel reminder) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete reminder?', style: GoogleFonts.poppins()),
        content: Text(
          'Are you sure you want to delete "${reminder.title}"?',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result == true) {
      await _reminderService.deleteReminder(reminder);
    }
    return result ?? false;
  }
}
