import 'package:aura_alert/navbar_pages/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_screen.dart';

class Question5Screen extends StatefulWidget {
  const Question5Screen({super.key});

  @override
  State<Question5Screen> createState() => _Question5ScreenState();
}

class _Question5ScreenState extends State<Question5Screen> {
  bool _isObscure = true;
  bool _isConfirmObscure = true;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isValid = false; // <--- Button enabled state

  @override
  void initState() {
    super.initState();

    // Listener to update button state when typing
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    setState(() {
      _isValid =
          _passwordController.text.isNotEmpty &&
              _confirmPasswordController.text.isNotEmpty &&
              _passwordController.text == _confirmPasswordController.text;
    });
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Signup error: ${e.code}");
      return null;
    }
  }

  Future<void> createUserInfo({
    required String name,
    required String phone,
    required String email,
    required bool isPatient,
  }) async {
    try {
      // Get reference to 'User's Info' collection
      CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("User's Info");

      // Create a new document with auto-generated ID
      await usersCollection.add({
        'name': name,
        'phone': phone,
        'email': email,
        'isPatient': isPatient,
        'createdAt': FieldValue.serverTimestamp(), // optional
      });

      print("User document created successfully!");
    } catch (e) {
      print("Error creating user document: $e");
    }
  }

  bool intToBool(int value) {
    return value != 0;
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

              // --- PASSWORD FIELD ---
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

              // --- CONFIRM PASSWORD FIELD ---
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
                        _isConfirmObscure ? Icons.visibility_off : Icons.visibility,
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

              // --- CONTINUE BUTTON ---
              ElevatedButton(
                onPressed: _isValid
                    ? () async {
                  if (kDebugMode) print("Password confirmed!");

                  /////////////////// sign up users account////////////////////////////
                  //load shared ref data
                  final prefs = await SharedPreferences.getInstance();
                  //get users email from shared ref
                  String? emailShared = prefs.getString('user_email');
                  if (emailShared == null) return; // safety check

                  //create users account
                  final user = await signUpWithEmail(
                    emailShared,
                    _confirmPasswordController.text.trim(),
                  );
                  if (user != null) {
                    if (kDebugMode) {
                      print("User created: ${user.email}");
                    }
                  } else {
                    if (kDebugMode) {
                      print("Failed to create account");
                    }
                    return; // stop execution if signup failed
                  }
                  /////////////////////////////////////////////////////////////////////

                  /////////////////// create User's Info Document ////////////////////////////
                  //after User's Info successfully created we will delete all shared ref data

                  //get all data stored in shared ref
                  int? choice = prefs.getInt('selectedOption');
                  String? phoneShared = prefs.getString('user_phone');
                  String? nameShared = prefs.getString('user_name');

                  try {
                    await createUserInfo(
                      name: nameShared ?? "",
                      phone: phoneShared ?? "",
                      email: emailShared,
                      isPatient: intToBool(choice ?? 0),
                    );
                    if (kDebugMode) print("User document created successfully!");

                    //////////////////clear shared preferences///////////////////////
                    await prefs.clear();
                    /////////////////////////////////////////////////////////////////

                    // Navigate to login screen
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MyNavBar()),
                    );
                  } catch (e) {
                    if (kDebugMode) print("Error creating user document: $e");
                  }
                  /////////////////////////////////////////////////////////////////////
                }
                    : null, // <---- Disabled when invalid
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isValid ? const Color(0xFF8e44ad) : Colors.grey, // <--- Grey when disabled
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: CustomText(
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
