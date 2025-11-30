// storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'reminder_model.dart';
import 'notification_service.dart';

class StorageService {
  static const String _remindersKey = 'reminders_data';

  // Save reminders to SharedPreferences
  static Future<void> saveReminders(List<ReminderModel> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final String remindersJson = json.encode(
      reminders.map((reminder) => reminder.toJson()).toList(),
    );
    await prefs.setString(_remindersKey, remindersJson);
  }

  // Load reminders from SharedPreferences
  static Future<List<ReminderModel>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString(_remindersKey);

    if (remindersJson != null && remindersJson.isNotEmpty) {
      final List<dynamic> remindersList = json.decode(remindersJson);
      return remindersList
          .map((json) => ReminderModel.fromJson(json))
          .toList();
    }
    return []; // Return empty list if no data found
  }

  // Add a new reminder
  static Future<void> addReminder(ReminderModel reminder) async {
    try {
      final List<ReminderModel> reminders = await loadReminders();
      reminders.add(reminder);
      await saveReminders(reminders);

      // Get the scheduled time
      DateTime scheduledTime = reminder.getScheduledDateTime();

      // Only schedule notification if it's in the future
      if (scheduledTime.isAfter(DateTime.now())) {
        await NotificationService.scheduleNotification(
          id: reminder.reminderId.hashCode,
          title: '⏰ Reminder: ${reminder.remindAbout}',
          body: 'Reminder for ${reminder.remindAbout} ${reminder.commonName}',
          scheduledTime: scheduledTime,
        );
        print('✅ Notification scheduled for: $scheduledTime');
      } else {
        print('⚠️ Reminder time is in the past, notification not scheduled');
      }
    } catch (e) {
      print('❌ Error adding reminder: $e');
      rethrow;
    }
  }

  // Remove a reminder by ID
  static Future<void> removeReminder(String reminderId) async {
    try {
      final List<ReminderModel> reminders = await loadReminders();
      reminders.removeWhere((reminder) => reminder.reminderId == reminderId);
      await saveReminders(reminders);

      // Cancel the notification
      await NotificationService.cancelNotification(reminderId.hashCode);
      print('✅ Reminder and notification removed');
    } catch (e) {
      print('❌ Error removing reminder: $e');
      rethrow;
    }
  }

  // Clear all reminders
  static Future<void> clearAllReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_remindersKey);

      // Cancel all notifications
      await NotificationService.cancelAllNotifications();
      print('✅ All reminders and notifications cleared');
    } catch (e) {
      print('❌ Error clearing reminders: $e');
      rethrow;
    }
  }

  // Update an existing reminder
  static Future<void> updateReminder(ReminderModel updatedReminder) async {
    try {
      final List<ReminderModel> reminders = await loadReminders();
      final index = reminders.indexWhere(
            (reminder) => reminder.reminderId == updatedReminder.reminderId,
      );

      if (index != -1) {
        reminders[index] = updatedReminder;
        await saveReminders(reminders);

        // Cancel old notification
        await NotificationService.cancelNotification(
          updatedReminder.reminderId.hashCode,
        );

        // Schedule new notification if in future
        DateTime scheduledTime = updatedReminder.getScheduledDateTime();
        if (scheduledTime.isAfter(DateTime.now())) {
          await NotificationService.scheduleNotification(
            id: updatedReminder.reminderId.hashCode,
            title: '⏰ Reminder: ${updatedReminder.remindAbout}',
            body: 'Reminder for ${updatedReminder.remindAbout} ${updatedReminder.commonName}',
            scheduledTime: scheduledTime,
          );
        }
        print('✅ Reminder updated successfully');
      }
    } catch (e) {
      print('❌ Error updating reminder: $e');
      rethrow;
    }
  }

  // Get reminder by ID
  static Future<ReminderModel?> getReminderById(String reminderId) async {
    try {
      final List<ReminderModel> reminders = await loadReminders();
      return reminders.firstWhere(
            (reminder) => reminder.reminderId == reminderId,
        orElse: () => throw Exception('Reminder not found'),
      );
    } catch (e) {
      print('❌ Error getting reminder: $e');
      return null;
    }
  }

  // Reschedule all reminders (useful after app restart or device reboot)
  static Future<void> rescheduleAllReminders() async {
    try {
      final List<ReminderModel> reminders = await loadReminders();

      for (var reminder in reminders) {
        DateTime scheduledTime = reminder.getScheduledDateTime();

        // Only reschedule future reminders
        if (scheduledTime.isAfter(DateTime.now())) {
          await NotificationService.scheduleNotification(
            id: reminder.reminderId.hashCode,
            title: '⏰ Reminder: ${reminder.remindAbout}',
            body: 'Reminder for ${reminder.remindAbout} ${reminder.commonName}',
            scheduledTime: scheduledTime,
          );
        }
      }
      print('✅ All reminders rescheduled');
    } catch (e) {
      print('❌ Error rescheduling reminders: $e');
    }
  }

  // Clean up past reminders (optional - call periodically)
  static Future<void> cleanupPastReminders() async {
    try {
      final List<ReminderModel> reminders = await loadReminders();
      final now = DateTime.now();

      // Remove reminders that are more than 24 hours old
      final activeReminders = reminders.where((reminder) {
        final scheduledTime = reminder.getScheduledDateTime();
        return scheduledTime.isAfter(now.subtract(const Duration(hours: 24)));
      }).toList();

      if (activeReminders.length != reminders.length) {
        await saveReminders(activeReminders);
        print('✅ Cleaned up ${reminders.length - activeReminders.length} past reminders');
      }
    } catch (e) {
      print('❌ Error cleaning up reminders: $e');
    }
  }
}