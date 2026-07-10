import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:mother_and_baby_smartcare/models/reminder_model.dart';

/// Single source of truth for all reminder scheduling. Uses the `alarm`
/// package for everything — both the real, full-screen "ring now" alarm
/// and the earlier "heads up, in N minutes" alert.
///
/// Why one package for both: the alarm package runs its own foreground
/// service, so it keeps working even if the app was fully killed by the
/// OS — something flutter_local_notifications cannot reliably guarantee
/// on aggressive OEMs (Xiaomi/Oppo/Vivo). Using it for both alerts keeps
/// the whole reminder system consistent and equally reliable.
///
/// Timezone note: dart's plain DateTime (via DateTime.now() or the local
/// DateTime(...) constructor) is already expressed in the device's own
/// local timezone. We never need to read or set a timezone manually —
/// whatever time the user's phone is set to is what gets used, and it
/// updates automatically if they travel or change their clock.
class AlarmClockService {
  AlarmClockService._internal();
  static final AlarmClockService _instance = AlarmClockService._internal();
  factory AlarmClockService() => _instance;

  bool _initialized = false;

  /// Call once in main(), before runApp().
  Future<void> init() async {
    if (_initialized) return;
    await Alarm.init();
    _initialized = true;
  }

  /// The main "it's time" alarm — loud, loops, full-screen, like a real
  /// alarm clock. Repeats are handled by re-scheduling the next
  /// occurrence when the alarm rings (see ring handling in main.dart).
  Future<void> scheduleMainAlarm(
      ReminderModel reminder, DateTime reminderDateTime) async {
    final settings = AlarmSettings(
      id: reminder.alarmId,
      dateTime: reminderDateTime,
      assetAudioPath: 'assets/sounds/alarm_sound.mp3',
      loopAudio: true,
      vibrate: true,
      volumeSettings: const VolumeSettings.fixed(
        volume: 1.0,
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: '🔔 ${reminder.title}',
        body: reminder.note,
        stopButton: 'Stop',
        icon: 'ic_launcher',
      ),
      androidFullScreenIntent: true,
      warningNotificationOnKill: true,
    );

    try {
      await Alarm.set(alarmSettings: settings);
      debugPrint(
          'Main alarm scheduled: ${reminder.title} at $reminderDateTime');
    } catch (e, st) {
      debugPrint('Failed to schedule main alarm ${reminder.id}: $e\n$st');
      rethrow;
    }
  }

  /// The earlier "heads up, in N minutes" alert. Rings briefly (does not
  /// loop) and is not a full-screen intent, so it behaves like a normal
  /// notification with sound rather than taking over the screen.
  Future<void> scheduleEarlyAlert(
      ReminderModel reminder, DateTime alertDateTime) async {
    final settings = AlarmSettings(
      id: reminder.earlyAlarmId,
      dateTime: alertDateTime,
      assetAudioPath: 'assets/sounds/alarm_sound.mp3',
      loopAudio: false,
      vibrate: true,
      volumeSettings: const VolumeSettings.fixed(
        volume: 1.0,
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: '⏰ Upcoming: ${reminder.title}',
        body: 'In ${reminder.remindBefore} minute(s) — ${reminder.note}',
        stopButton: 'Dismiss',
        icon: 'ic_launcher',
      ),
      androidFullScreenIntent: false,
      warningNotificationOnKill: false,
    );

    try {
      await Alarm.set(alarmSettings: settings);
      debugPrint('Early alert scheduled: ${reminder.title} at $alertDateTime');
    } catch (e, st) {
      debugPrint('Failed to schedule early alert ${reminder.id}: $e\n$st');
      rethrow;
    }
  }

  /// Schedules whichever alerts are needed for a reminder: always the
  /// main alarm, plus the early alert if remindBefore > 0. If the given
  /// time has already passed today and the reminder repeats, it rolls
  /// forward to the next valid occurrence.
  Future<void> scheduleReminder(
      ReminderModel reminder, DateTime reminderDateTime) async {
    final DateTime target = _nextOccurrence(reminderDateTime, reminder.repeat);

    await scheduleMainAlarm(reminder, target);

    if (reminder.remindBefore > 0) {
      final earlyTime =
          target.subtract(Duration(minutes: reminder.remindBefore));
      // Only schedule the early alert if it's still in the future.
      if (earlyTime.isAfter(DateTime.now())) {
        await scheduleEarlyAlert(reminder, earlyTime);
      }
    }
  }

  /// Rolls a date/time forward to the next valid occurrence based on the
  /// repeat setting, if the given time has already passed.
  DateTime _nextOccurrence(DateTime dateTime, String repeat) {
    DateTime target = dateTime;
    final now = DateTime.now();
    if (!target.isAfter(now)) {
      switch (repeat) {
        case 'Daily':
          while (!target.isAfter(now)) {
            target = target.add(const Duration(days: 1));
          }
          break;
        case 'Weekly':
          while (!target.isAfter(now)) {
            target = target.add(const Duration(days: 7));
          }
          break;
        case 'Monthly':
          while (!target.isAfter(now)) {
            target = DateTime(target.year, target.month + 1, target.day,
                target.hour, target.minute);
          }
          break;
        default:
          // One-off reminder in the past — push it 1 minute ahead so the
          // plugin doesn't reject it outright; the UI should generally
          // prevent picking past times for "None" repeats anyway.
          target = now.add(const Duration(minutes: 1));
      }
    }
    return target;
  }

  /// Called when a repeating alarm finishes ringing, to schedule its next
  /// occurrence (the alarm package fires once per Alarm.set call).
  Future<void> rescheduleIfRepeating(
      ReminderModel reminder, DateTime lastFiredAt, String repeat) async {
    if (repeat == 'None') return;
    Duration interval;
    switch (repeat) {
      case 'Daily':
        interval = const Duration(days: 1);
        break;
      case 'Weekly':
        interval = const Duration(days: 7);
        break;
      case 'Monthly':
        interval = const Duration(days: 30); // approximate, refined below
        break;
      default:
        return;
    }
    DateTime next = lastFiredAt.add(interval);
    if (repeat == 'Monthly') {
      next = DateTime(lastFiredAt.year, lastFiredAt.month + 1, lastFiredAt.day,
          lastFiredAt.hour, lastFiredAt.minute);
    }
    await scheduleMainAlarm(reminder, next);
  }

  Future<void> cancelForReminder(ReminderModel reminder) async {
    await Alarm.stop(reminder.alarmId);
    await Alarm.stop(reminder.earlyAlarmId);
    debugPrint('Cancelled alarms for reminder: ${reminder.id}');
  }

  Future<void> cancelAll() async {
    final alarms = await Alarm.getAlarms();
    for (final a in alarms) {
      await Alarm.stop(a.id);
    }
    debugPrint('All alarms cancelled');
  }

  /// Fires a test alarm 5 seconds from now — wire to a debug button to
  /// verify sound/vibration/full-screen behavior on a given device.
  Future<void> scheduleTestAlarm() async {
    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: 999999,
        dateTime: DateTime.now().add(const Duration(seconds: 5)),
        assetAudioPath: 'assets/sounds/alarm_sound.mp3',
        loopAudio: true,
        vibrate: true,
        volumeSettings: const VolumeSettings.fixed(
          volume: 1.0,
          volumeEnforced: true,
        ),
        notificationSettings: const NotificationSettings(
          title: '🔔 Test Alarm',
          body: 'If you can hear and see this, everything works.',
          stopButton: 'Stop',
          icon: 'ic_launcher',
        ),
        androidFullScreenIntent: true,
        warningNotificationOnKill: true,
      ),
    );
  }
}
