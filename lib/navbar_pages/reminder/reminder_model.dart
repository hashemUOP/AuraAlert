import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String reminderId;
  final String about;
  final String user;
  final DateTime startingDate;
  final DateTime time;

  ReminderModel({
    required this.reminderId,
    required this.about,
    required this.user,
    required this.startingDate,
    required this.time,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'about': about,
      'user': user,
      'starting_date': Timestamp.fromDate(startingDate),
      'time': Timestamp.fromDate(time),
    };
  }

  // Create from Firestore Document
  factory ReminderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReminderModel(
      reminderId: doc.id,
      about: data['about'] ?? '',
      user: data['user'] ?? '',
      startingDate: (data['starting_date'] as Timestamp).toDate(),
      time: (data['time'] as Timestamp).toDate(),
    );
  }
}