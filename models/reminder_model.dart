import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  String? id; // Firestore document id
  String userId;
  String title;
  String note;
  String type; // Medicine, Feeding, Appointment, Vaccination, Checkup, Other
  String date; // stored as dd/MM/yyyy
  String time; // stored as hh:mm a (e.g. 09:30 AM)
  int remindBefore; // minutes before "time" to send an early heads-up alert
  String repeat; // None, Daily, Weekly, Monthly
  bool isCompleted;
  int color; // index into the app's reminder color palette
  int alarmId; // integer id used by the alarm package (must be unique)
  Timestamp? createdAt;
  Timestamp? updatedAt;

  ReminderModel({
    this.id,
    required this.userId,
    required this.title,
    required this.note,
    required this.type,
    required this.date,
    required this.time,
    this.remindBefore = 10,
    this.repeat = "None",
    this.isCompleted = false,
    this.color = 0,
    required this.alarmId,
    this.createdAt,
    this.updatedAt,
  });

  /// The id used for the early heads-up alert alarm. Offset from the main
  /// alarmId so the two never collide.
  int get earlyAlarmId => alarmId + 1000000;

  factory ReminderModel.fromMap(Map<String, dynamic> map, String id) {
    return ReminderModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      note: map['note'] ?? '',
      type: map['type'] ?? 'Other',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      remindBefore: map['remindBefore'] ?? 10,
      repeat: map['repeat'] ?? 'None',
      isCompleted: map['isCompleted'] ?? false,
      color: map['color'] ?? 0,
      alarmId: map['alarmId'] ?? map['notificationId'] ?? 0,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  factory ReminderModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReminderModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'note': note,
      'type': type,
      'date': date,
      'time': time,
      'remindBefore': remindBefore,
      'repeat': repeat,
      'isCompleted': isCompleted,
      'color': color,
      'alarmId': alarmId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
