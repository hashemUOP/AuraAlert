import 'package:aura_alert/navbar_pages/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../navbar_pages/location/LocationManager.dart';
import '../login/login_screen.dart';

class Question5Screen extends StatefulWidget {
  const Question5Screen({super.key});

  @override
  State<Question5Screen> createState() => _Question5ScreenState();
}

class _Question5ScreenState extends State<Question5Screen> {
  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false; // controls loading spinner

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    setState(() {
      _isValid =
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  // --- 1. AUTH HELPER ---
  Future<User?> signUpWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print("Signup error: ${e.code}");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sign Up Failed: ${e.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  // --- 2. DATABASE HELPER ---
  Future<void> createUserInfo({
    required String name,
    required String phone,
    required String email,
    required bool isPatient,
    required String uid,
  }) async {
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      if (kDebugMode) print("Warning: Could not get FCM token: $e");
    }

    CollectionReference usersCollection = FirebaseFirestore.instance.collection(
      "UsersInfo",
    );

    try {
      await usersCollection.doc(email).set({
        'uid': uid,
        'name': name,
        'phone': phone,
        'email': email,
        'isPatient': isPatient,
        'fcm_token': token,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Database write failed: $e");
    }
  }

  bool intToBool(int value) => value != 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // --- HEADER ---
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

              // --- TITLE ---
              const Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  'Create a Password',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fromLeft: 0.0,
                ),
              ),
              const SizedBox(height: 30),

              // --- PASSWORD FIELDS ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  keyboardType: TextInputType.visiblePassword,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => _isObscure = !_isObscure);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmObscure,
                  keyboardType: TextInputType.visiblePassword,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmObscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => _isConfirmObscure = !_isConfirmObscure);
                      },
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // --- BUTTON WITH ROLLBACK LOGIC ---
              ElevatedButton(
                onPressed: (_isValid && !_isLoading)
                    ? () async {
                        setState(() => _isLoading = true);

                        final prefs = await SharedPreferences.getInstance();
                        String? emailShared = prefs.getString('user_email');

                        if (emailShared == null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Error: Email missing from session",
                                ),
                              ),
                            );
                            setState(() => _isLoading = false);
                          }
                          return;
                        }

                        // 1. Create User in Firebase Auth
                        final user = await signUpWithEmail(
                          context,
                          emailShared,
                          _confirmPasswordController.text.trim(),
                        );

                        if (user == null) {
                          setState(() => _isLoading = false);
                          return; // Auth failed, handled in function
                        }

                        // 2. Try saving User Info to Firestore
                        try {
                          int? choice = prefs.getInt('selectedOption');
                          String? phoneShared = prefs.getString('user_phone');
                          String? nameShared = prefs.getString('user_name');

                          await createUserInfo(
                            uid: user.uid,
                            name: nameShared ?? "",
                            phone: phoneShared ?? "",
                            email: emailShared,
                            isPatient: intToBool(choice ?? 0),
                          );

                          // SUCCESS: Clear cache and Navigate
                          await prefs.clear();
                          if (!mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LocationManager(child: const MyNavBar()),
                            ),
                          );
                        } catch (e) {
                          // 🚨 FAILURE DETECTED - ROLLBACK! 🚨
                          if (kDebugMode) print("CRITICAL DATABASE ERROR: $e");
                          if (kDebugMode)
                            print("Rolling back account creation...");

                          // DELETE THE AUTH ACCOUNT we just made
                          try {
                            await user.delete();
                            if (kDebugMode)
                              print("Account deleted successfully.");
                          } catch (delErr) {
                            if (kDebugMode) print("Rollback failed: $delErr");
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Setup failed. Account rolled back. Please try again.\nError: $e",
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                            setState(() => _isLoading = false);
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isValid
                      ? const Color(0xFF8e44ad)
                      : Colors.grey,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : CustomText(
                        "Create Account",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(_isValid ? 1.0 : 0.6),
                        fromLeft: 0.0,
                      ),
              ),

              const SizedBox(height: 20),

              // --- LOGIN LINK ---
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
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
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
