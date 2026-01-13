import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import '../signup/question_1.dart';
import  'package:aura_alert/global_widgets/custom_text.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4a4a58),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/AuraAlert_logo.png',
                        width: 180,
                      ),
                    ),
                    const SizedBox(height: 50),

                    const CustomText(
                      'Feel safer. Live Better.',
                      textAlign: TextAlign.center,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fromLeft: 0.0,
                    ),
                    const SizedBox(height: 15),

                    CustomText(
                      'AuraAlert helps families detect seizures and manage epilepsy with confidence.',
                      textAlign: TextAlign.center,
                      fontSize: 18,
                      color: Colors.grey[300],
                      fromLeft: 0.0,
                    ),
                    const SizedBox(height: 20),

                    CustomText(
                      'Trusted by thousands of families',
                      textAlign: TextAlign.center,
                      fontSize: 16,
                      color: Colors.grey[400],
                      fromLeft: 0.0,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Question1Screen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8e44ad),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 24),
                    CustomText(
                      "Let's Get Started",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fromLeft: 0.0,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    'Already have an account? ',
                    fontSize: 16,
                    color: Colors.grey[300],
                    fromLeft: 0.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const CustomText(
                      'Log in',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFbb86fc),
                      fromLeft: 0.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}