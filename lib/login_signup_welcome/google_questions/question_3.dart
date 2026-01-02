import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../navbar_pages/location/LocationManager.dart';
import '../login/login_screen.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';

class Question3Screen extends StatefulWidget {
  const Question3Screen({super.key});

  @override
  State<Question3Screen> createState() => _Question3ScreenState();
}

class _Question3ScreenState extends State<Question3Screen> {
  String? _email;
  User? _currentUser; // To hold the full user object (for UID)
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Get the currently logged-in user (e.g., from Google Sign-In)
    _currentUser = FirebaseAuth.instance.currentUser;
    _email = _currentUser?.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> createUserInfo({
    required String uid,
    required String name,
    required String phone,
    required String email,
    required bool isPatient,
  }) async {
    String? token;

    // 1. Try to get the token safely. If it fails, we just continue with null.
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      if (kDebugMode) {
        print("Warning: Could not get FCM token. Continuing without it. Error: $e");
      }
    }

    // 2. Reference the collection
    CollectionReference usersCollection =
    FirebaseFirestore.instance.collection("UsersInfo");

    // 3. Save Data (This will now run even if token failed)
    // We rethrow the error here so the 'onPressed' knows if the SAVE failed.
    try {
      await usersCollection.doc(email).set({
        'uid': uid,
        'name': name,
        'phone': phone,
        'email': email,
        'isPatient': isPatient,
        'fcm_token': token, // might be null, which is fine
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print("User document created successfully");
      }
    } catch (e) {
      // Rethrow the error so the UI knows to show a SnackBar or stop navigation
      throw Exception("Database write failed: $e");
    }
  }

  bool intToBool(int value) {
    return value != 0;
  }

  Future<void> _saveNameInSharedRef() async {
    String name = _nameController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    String? nameShared = prefs.getString('user_name');
    if (kDebugMode) {
      print('User name in shared ref : $nameShared');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const CustomText(
                    'Sign Up',
                    fontSize: 16,
                    color: Colors.black54,
                    fromLeft: 0.0,
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  'Enter your Name',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fromLeft: 0.0,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Name (Optional)',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await _saveNameInSharedRef();

                  // Safety checks
                  if (_email == null || _currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error: User not authenticated")),
                    );
                    return;
                  }

                  // Load shared ref data
                  final prefs = await SharedPreferences.getInstance();
                  int? choice = prefs.getInt('selectedOption');
                  String? phoneShared = prefs.getString('user_phone');
                  String? nameShared = prefs.getString('user_name');

                  try {
                    await createUserInfo(
                      uid: _currentUser!.uid,
                      name: nameShared ?? "",
                      phone: phoneShared ?? "",
                      isPatient: intToBool(choice ?? 0),
                      email: _email!,
                    );

                    // ONLY clear prefs and navigate if the above line succeeded
                    if (kDebugMode) print("User document created successfully!");

                    await prefs.clear();

                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) =>  LocationManager(child: const MyNavBar())),
                    );

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Save failed: $e"), backgroundColor: Colors.red),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8e44ad),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const CustomText(
                  "Continue",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fromLeft: 0.0,
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    "Already have an account? ",
                    fontSize: 16,
                    color: Colors.grey[600],
                    fromLeft: 0.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (Route<dynamic> route) => route.isFirst,
                      );
                    },
                    child: const CustomText(
                      'Log In',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8e44ad),
                      fromLeft: 0.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}