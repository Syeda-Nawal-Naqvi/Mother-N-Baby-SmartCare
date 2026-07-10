import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mother_and_baby_smartcare/models/reminder_model.dart';
import 'package:mother_and_baby_smartcare/services/alarm_clock_service.dart';

/// Handles all Firestore reads/writes for the Reminder module, and keeps
/// scheduled alarms in sync with whatever is stored in Firestore.
class ReminderService {
  final AlarmClockService _alarmClockService = AlarmClockService();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// User-scoped collection: users/{uid}/reminders
  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _uid;
    if (uid == null) {
      throw StateError('No authenticated user.');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reminders');
  }

  /// Real-time stream of the current user's reminders, ordered by date.
  ///
  /// Sorting is done client-side so it doesn't require a Firestore index.
  Stream<List<ReminderModel>> streamReminders() {
    if (_uid == null) return const Stream.empty();

    return _collection.snapshots().map((snap) {
      final list = snap.docs.map((d) => ReminderModel.fromSnapshot(d)).toList();
      list.sort((a, b) {
        try {
          final dateA = DateFormat('dd/MM/yyyy').parse(a.date);
          final dateB = DateFormat('dd/MM/yyyy').parse(b.date);
          return dateA.compareTo(dateB);
        } catch (_) {
          return 0;
        }
      });
      return list;
    });
  }

  /// Generates an id safely within the 32-bit range the alarm package expects,
  /// leaving headroom for the +1,000,000 early-alert offset.
  int _generateAlarmId() => Random().nextInt(1000000000) + 1;

  Future<void> addReminder({
    required String title,
    required String note,
    required String type,
    required String date,
    required String time,
    required int remindBefore,
    required String repeat,
    required int color,
    required DateTime reminderDateTime,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('No authenticated user.');

    final reminder = ReminderModel(
      userId: uid,
      title: title,
      note: note,
      type: type,
      date: date,
      time: time,
      remindBefore: remindBefore,
      repeat: repeat,
      color: color,
      alarmId: _generateAlarmId(),
    );

    final docRef = await _collection.add(reminder.toMap());
    reminder.id = docRef.id;

    await _alarmClockService.scheduleReminder(reminder, reminderDateTime);
  }

  Future<void> updateReminder(
    ReminderModel reminder,
    DateTime reminderDateTime,
  ) async {
    if (reminder.id == null) return;

    await _collection.doc(reminder.id).update(reminder.toMap());

    // Cancel the old schedule, then reschedule with the updated values.
    await _alarmClockService.cancelForReminder(reminder);
    await _alarmClockService.scheduleReminder(reminder, reminderDateTime);
  }

  Future<void> markCompleted(ReminderModel reminder, bool isCompleted) async {
    if (reminder.id == null) return;

    await _collection.doc(reminder.id).update({
      'isCompleted': isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (isCompleted) {
      await _alarmClockService.cancelForReminder(reminder);
    }
  }

  Future<void> deleteReminder(ReminderModel reminder) async {
    if (reminder.id == null) return;

    await _alarmClockService.cancelForReminder(reminder);
    await _collection.doc(reminder.id).delete();
  }
}
