import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests every permission the reminder/alarm system needs. Call
/// AlarmPermissions.requestAll() once, right after login or on the
/// dashboard's first frame.
class AlarmPermissions {
  /// Returns true only if every critical permission was granted.
  static Future<bool> requestAll() async {
    if (!Platform.isAndroid) return true;

    final notifStatus = await Permission.notification.request();

    bool exactAlarmGranted = true;
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    if (!exactAlarmStatus.isGranted) {
      final result = await Permission.scheduleExactAlarm.request();
      exactAlarmGranted = result.isGranted;
    }

    // Not strictly required, but strongly recommended so OEM battery
    // managers don't kill the alarm before it fires.
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    final allGranted = notifStatus.isGranted && exactAlarmGranted;
    debugPrint(
        'AlarmPermissions -> notifications: ${notifStatus.isGranted}, exactAlarm: $exactAlarmGranted');
    return allGranted;
  }
}
