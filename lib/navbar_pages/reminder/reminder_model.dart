// reminder_model.dart
import 'package:intl/intl.dart';

class ReminderModel {
  final String reminderId;
  final String reminderDate;
  final String reminderTime;
  final String commonName;
  final String remindAbout;

  ReminderModel({
    required this.reminderId,
    required this.reminderDate,
    required this.reminderTime,
    required this.commonName,
    required this.remindAbout,
  });

  Map<String, dynamic> toJson() {
    return {
      'reminder_id': reminderId,
      'reminder_date': reminderDate,
      'reminder_time': reminderTime,
      'common_name': commonName,
      'remind_about': remindAbout,
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      reminderId: json['reminder_id'],
      reminderDate: json['reminder_date'],
      reminderTime: json['reminder_time'],
      commonName: json['common_name'],
      remindAbout: json['remind_about'],
    );
  }

  // Parse the reminder date and time into a DateTime object
  DateTime getScheduledDateTime() {
    try {
      // Combine date and time strings
      String dateTimeString = '$reminderDate $reminderTime';

      // Try multiple date formats to handle different formats
      List<DateFormat> formats = [
        DateFormat('MMM dd, yyyy hh:mm a'), // e.g., "Dec 25, 2024 10:30 AM"
        DateFormat('MMM dd, yyyy HH:mm'), // e.g., "Dec 25, 2024 22:30"
        DateFormat('yyyy-MM-dd hh:mm a'), // e.g., "2024-12-25 10:30 AM"
        DateFormat('yyyy-MM-dd HH:mm'), // e.g., "2024-12-25 22:30"
        DateFormat('dd/MM/yyyy hh:mm a'), // e.g., "25/12/2024 10:30 AM"
        DateFormat('dd/MM/yyyy HH:mm'), // e.g., "25/12/2024 22:30"
        DateFormat('MM/dd/yyyy hh:mm a'), // e.g., "12/25/2024 10:30 AM"
        DateFormat('MM/dd/yyyy HH:mm'), // e.g., "12/25/2024 22:30"
      ];

      // Try each format
      for (var format in formats) {
        try {
          return format.parse(dateTimeString);
        } catch (e) {
          continue;
        }
      }

      // If no format works, try parsing date and time separately
      return _parseManually();
    } catch (e) {
      print('Error parsing date/time: $e');
      // Return a future date to avoid immediate notification
      return DateTime.now().add(const Duration(minutes: 1));
    }
  }

  // Manual parsing as fallback
  DateTime _parseManually() {
    try {
      // Parse time first
      DateTime timeComponent = DateFormat('hh:mm a').parse(reminderTime);

      // Parse date
      DateTime dateComponent = DateFormat('MMM dd, yyyy').parse(reminderDate);

      // Combine date and time
      return DateTime(
        dateComponent.year,
        dateComponent.month,
        dateComponent.day,
        timeComponent.hour,
        timeComponent.minute,
      );
    } catch (e) {
      print('Manual parsing failed: $e');
      return DateTime.now().add(const Duration(minutes: 1));
    }
  }

  // Check if reminder is in the past
  bool isPastReminder() {
    return getScheduledDateTime().isBefore(DateTime.now());
  }

  // Get formatted display string
  String getFormattedDateTime() {
    try {
      DateTime dt = getScheduledDateTime();
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dt);
    } catch (e) {
      return '$reminderDate - $reminderTime';
    }
  }
}