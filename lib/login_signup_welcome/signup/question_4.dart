import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import 'question_5.dart';
import  'package:aura_alert/global_widgets/custom_text.dart';


class Question4Screen extends StatelessWidget {
  const Question4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // --- HEADER & BACK ARROW ---
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
                  const SizedBox(width: 48), // To balance the IconButton
                ],
              ),
              const SizedBox(height: 30),

              // --- TITLE ---
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

              // --- name INPUT WIDGET ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [



                    // --- Name TEXT FIELD ---
                    Expanded(
                      child: TextField(
                        // This brings up the numeric keyboard
                        keyboardType: TextInputType.text,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Name (Optional)',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          // Remove the default border
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(), // Pushes content below to the bottom

              // --- CONTINUE BUTTON ---
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Question5Screen()),
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

              // --- LOG IN LINK ---
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
                      // Pop all routes until the welcome screen and then push login
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