import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_screen.dart';
import 'question_3.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';
import 'package:aura_alert/login_signup_welcome/auth_services.dart';

class Question2Screen extends StatefulWidget {
  const Question2Screen({super.key});

  @override
  State<Question2Screen> createState() => _Question2ScreenState();
}

class _Question2ScreenState extends State<Question2Screen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();

  bool _isEmailValid = false;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // makes sure that the entered email has valid email format entered to continue
  void _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
  }

  Future<bool> emailExistsInFirestore(String email) async {
    try {
      // Standardize the input
      final cleanEmail = email.toLowerCase().trim();

      final AggregateQuerySnapshot query = await FirebaseFirestore.instance
          .collection('UsersInfo')
          .where('email', isEqualTo: cleanEmail)
          .count()
          .get();

      // Returns TRUE if the count is greater than 0
      return query.count! > 0;

    } catch (e) {
      print("Error checking email existence: $e");
      return false;
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
                  'Enter your email',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fromLeft: 0.0,
                ),
              ),
              const SizedBox(height: 30),

              // --- EMAIL INPUT ---
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  _validateEmail(value);
                },
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _isEmailValid
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: CustomText(
                      'Or',
                      fontSize: 14,
                      color: Colors.grey[600],
                      fromLeft: 0.0,
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  setState(() => isLoading = true);
                  await _authService.handleGoogleSignIn(context);
                  setState(() => isLoading = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google_logo.png',
                      height: 22,
                      width: 22,
                    ),
                    const SizedBox(width: 12),
                    const CustomText(
                      'Continue with Google',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fromLeft: 0.0,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- CONTINUE BUTTON ---
              ElevatedButton(
                onPressed: _isEmailValid && !isLoading
                    ? () async {
                  setState(() => isLoading = true);

                  // Check Firebase
                  bool exists = await emailExistsInFirestore(_emailController.text);

                  // Ensure widget is still on screen before using context
                  if (!mounted) return;

                  setState(() => isLoading = false);

                  if (exists) {
                    // --- SHOW SNACKBAR & STAY ON PAGE ---
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("This email is already registered."),
                        backgroundColor: Colors.redAccent, // Red for error/warning
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    //////////////////////////////SharedPreferences///////////////////////////////////////
                    // Save email to SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('user_email', _emailController.text.trim());

                    //print the saved data/////////////////////////////
                    String? email = prefs.getString('user_email');
                    print("User entered email : $email");
                    ////////////////////////////////////////////////////////////////////////////////////////

                    // Navigate to the next screen
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Question3Screen(),
                      ),
                    );
                  }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8e44ad),
                  disabledBackgroundColor: Colors.grey[300],
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : CustomText(
                  "Continue",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isEmailValid ? Colors.white : Colors.grey[600],
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
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