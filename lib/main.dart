import 'dart:async'; // Added for StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aura_alert/login_signup_welcome/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';
import 'package:aura_alert/login_signup_welcome/auth_services.dart';
import 'package:aura_alert/gemini_api_key.dart';
import 'package:aura_alert/navbar_pages/reminder/notification_service.dart';

// --- NEW IMPORTS FOR NOTIFICATIONS ---
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// --- 1. DEFINE BACKGROUND HANDLER (Must be top-level) ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

// --- 2. DEFINE NOTIFICATION CHANNEL (Must match Node.js code) ---
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'emergency_channel_v2',
  'Emergency Alerts',
  description: 'High priority alerts for patient seizures',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('alarm_sound'),
);

// --- 3. INITIALIZE LOCAL NOTIFICATIONS PLUGIN ---
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- 4. SETUP FIREBASE MESSAGING ---
  // A. Set the background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // B. Create the Notification Channel (Android)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // C. Set Foreground Presentation Options (iOS/Android)
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  Gemini.init(apiKey: apiKey);

  await NotificationService.initialize();

  await _deleteSharedData();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // --- 5. SETUP FOREGROUND LISTENER ---
    // This allows the notification to show a visual alert even if the app is OPEN.
    var initializationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If notification data exists, show it manually using LocalNotifications
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher', // Ensure this icon exists in android/app/src/main/res/mipmap-*
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medicine App',
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder(
            future: _readSharedData(),
            builder: (context, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                      child: CircularProgressIndicator(color: Colors.blue)),
                );
              }

              // --- 6. UPDATE TOKEN ON LOGIN ---
              // Best practice: Ensure Firestore has the latest token for this user
              _updateMyToken();

              return const MyNavBar();
            },
          );
        }

        return const WelcomeScreen();
      },
    );
  }

  // Helper to keep token fresh in Firestore
  Future<void> _updateMyToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('UsersInfo')
            .doc(user.email)
            .update({'fcm_token': token}); // Ensure field matches Firestore
        if (kDebugMode) print("FCM Token refreshed for ${user.email}");
      }
    }
  }
}

// --- Helper Functions ---

Future<void> _deleteSharedData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('selectedOption');
  await prefs.remove('user_email');
  await prefs.remove('user_phone');
  await prefs.remove('user_name');

  if (kDebugMode) {
    print("All signup shared pref data has been cleared.");
  }
}

Future<void> _readSharedData() async {
  bool? isPatient = await getIsPatient();

  if (isPatient != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPatient', isPatient);

    if (kDebugMode) {
      print("Success: Saved isPatient = $isPatient to SharedPreferences");
    }
  } else {
    if (kDebugMode) {
      print("Warning: Could not fetch isPatient status (returned null).");
    }
  }
}

Future<bool?> getIsPatient() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final query = await FirebaseFirestore.instance
        .collection('UsersInfo')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final data = query.docs.first.data();
    return data['isPatient'] as bool?;
  } catch (e) {
    if (kDebugMode) {
      print('Error getting isPatient: $e');
    }
    return null;
  }
}