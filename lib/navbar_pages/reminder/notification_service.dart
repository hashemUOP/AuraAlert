import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Initialize timezone database
    tz.initializeTimeZones();

    // 2. Define platform-specific settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 3. Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle logic when user taps the notification
        print('Notification tapped: ${details.payload}');
      },
    );

    // Request Android 13+ permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Prevent scheduling notifications in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      print('Warning: Cannot schedule notification for a past time.');
      return;
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      // Converts local DateTime to TZDateTime required by the plugin
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel', // Channel ID
          'Reminders',        // Channel Name
          channelDescription: 'Scheduled reminders for medicine and appointments',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // FIXED: uiLocalNotificationDateInterpretation is removed as it is
      // no longer required in the latest version of the package.
    );

    print('✅ Notification "$title" scheduled for: $scheduledTime');
  }

  /// Cancels a specific notification by its ID
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print('otificatinon $id cancelled');
  }

  /// Cancels all pending notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('All notifications cancelled');
  }
}