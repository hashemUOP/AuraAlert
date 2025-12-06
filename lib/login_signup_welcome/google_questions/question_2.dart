import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_screen.dart';
import 'package:aura_alert/login_signup_welcome/google_questions/question_3.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';

class Question2Screen extends StatefulWidget {
  const Question2Screen({super.key});

  @override
  State<Question2Screen> createState() => _Question2ScreenState();
}

class _Question2ScreenState extends State<Question2Screen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _savePhoneInSharedRef() async {
    String phone = _phoneController.text.trim();

    //save the entered phone number to the shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phone);

    String? phone_shared = prefs.getString('user_phone');
    print('User phone in shared ref : $phone_shared');
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
                  'Enter your phone number',
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
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset('assets/images/flag.png', width: 30),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _phoneController, // <-- Add controller
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Phone Number (Optional)',
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
                  await _savePhoneInSharedRef(); // <-- Save phone if entered
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Question3Screen()),
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
