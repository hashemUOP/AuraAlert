import 'package:flutter/material.dart';
import  'package:aura_alert/global_widgets/custom_text.dart';
import '../login/login_screen.dart';
import '../screens/home_screen.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    'Log In',
                    fontSize: 16,
                    color: Colors.black54,
                    fromLeft: 0.0,
                  ),
                  const SizedBox(width: 48), // To balance the IconButton
                ],
              ),
              const SizedBox(height: 30),


              const Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  'Enter your account information',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fromLeft: 0.0,
                ),
              ),
              const SizedBox(height: 30),


              //---Email Field---
              TextField(
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // No visible border
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // --- Password INPUT FIELD ---
              TextField(
                obscureText: true,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // No visible border
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- "OR" DIVIDER ---
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

              // --- GOOGLE Log IN BUTTON ---
              ElevatedButton(
                onPressed: () {
                  // TODO: Add Google Sign-In logic
                  print('Continue with Google pressed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black, // Color for text and icon
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0, // No shadow
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/google_logo.png',
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

              // Pushes content below to the bottom
              const Spacer(),

              // --- CONTINUE BUTTON ---
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (Route<dynamic> route) => false,
                  );
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


            ],
          ),
        ),
      ),
    );
  }
}