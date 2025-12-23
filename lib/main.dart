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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Gemini.init(apiKey: apiKey);
  await NotificationService.initialize();
  await _deleteSharedData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp( // Added const
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
        // 1. Waiting for Firebase Auth to check if user is logged in
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }

        // 2. User IS logged in
        if (snapshot.hasData) {
          // 3. NOW wait for _readSharedData to finish before showing MyNavBar
          return FutureBuilder(
            future: _readSharedData(), // read users shared data before navigating him to MyNavBar page if he was logged in
            builder: (context, dataSnapshot) {
              // While fetching name from Firestore...
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator(color: Colors.blue)), // Different color to distinguish steps
                );
              }

              // Done fetching! Navigate to App
              return const MyNavBar();
            },
          );
        }

        // 4. User is NOT logged in
        return const WelcomeScreen();
      },
    );
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

// Future<void> _createSharedData() async{
//
// }

Future<void> _readSharedData() async{



  //////////////////////////////////////////////////////////////////////////////////
                ///read user state is patient or caregiver
  //////////////////////////////////////////////////////////////////////////////////

  bool? isPatient = await getIsPatient();

  // if we successfully got a value from getIsPatient then it will be stored in shared pref var
  if (isPatient != null) {
    final prefs = await SharedPreferences.getInstance();

    // save as a boolean
    await prefs.setBool('isPatient', isPatient);

    if (kDebugMode) {
      print("Success: Saved isPatient = $isPatient to SharedPreferences");
    }
  } else {
    if (kDebugMode) {
      print("Warning: Could not fetch isPatient status (returned null).");
    }
  }
  //////////////////////////////////////////////////////////////////////////////////
              ///end of read user state is patient or caregiver
  //////////////////////////////////////////////////////////////////////////////////

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