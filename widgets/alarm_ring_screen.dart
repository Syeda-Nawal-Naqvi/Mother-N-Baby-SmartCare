import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:alarm/alarm.dart';

/// Full-screen page shown the moment a reminder alarm rings — mirrors a
/// real device alarm clock (current time, title/body, Stop/Snooze).
/// Pushed on top of everything via the global navigatorKey whenever
/// Alarm.ringStream fires, no matter which screen the user was on, or
/// even if the app was just relaunched because of the alarm.
class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  static const Color primary = Color(0xFFE91E8C);

  @override
  Widget build(BuildContext context) {
    final title = widget.alarmSettings.notificationSettings.title;
    final body = widget.alarmSettings.notificationSettings.body;
    final now = DateTime.now();

    return PopScope(
      canPop: false, // don't let the back button dismiss a ringing alarm
      child: Scaffold(
        backgroundColor: const Color(0xFF3D1A2E),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(now),
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('EEEE, dd MMMM').format(now),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.notifications_active_rounded,
                    color: primary, size: 90),
                Column(
                  children: [
                    Text(
                      title.isEmpty ? 'Reminder' : title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _stop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Stop',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _snooze,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Snooze 5 min',
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _stop() async {
    debugPrint('AlarmRingScreen STOP for alarm id: ${widget.alarmSettings.id}');
    await Alarm.stop(widget.alarmSettings.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _snooze() async {
    await Alarm.stop(widget.alarmSettings.id);
    await Alarm.set(
      alarmSettings: widget.alarmSettings.copyWith(
        dateTime: DateTime.now().add(const Duration(minutes: 5)),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }
}
