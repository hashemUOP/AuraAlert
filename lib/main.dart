import 'package:flutter/material.dart';
import 'package:aura_alert/login_signup_welcome/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';
import 'package:aura_alert/login_signup_welcome/auth_services.dart';
import 'package:aura_alert/gemini_api_key.dart';
import 'package:aura_alert/navbar_pages/reminder/notification_service.dart';

Future<void> main() async {
  //initialize connection between project and firebase includes all services such as firestore,auth
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Gemini.init(apiKey: apiKey);

  // Initialize notification service
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medicine App',
      theme: ThemeData(
        fontFamily: "BungeeSpice",
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();

    // Listen to auth state changes
    _authService.userChanges.listen((User? user) { //check settings.dart line 76, when user is signed out user variable User? user becomes null
      if (user != null) {
        // if user has an account in firebase auth whether he is signed by phone , google , or any other way is signed in, navigate to MyNavBar
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyNavBar()),
        );
      } else {
        // User is signed out, navigate to Login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    });
  }//this is make sure if user is signed in with google account to be transferred to Home everytime he opens app , and if not he will be transferred to Login page

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while checking auth state
    return  Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.green.shade500,)),
    );
  }
}
