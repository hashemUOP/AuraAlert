import 'package:flutter/material.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';
import  'package:aura_alert/global_widgets/custom_text.dart';

class Question6Screen extends StatelessWidget {
  const Question6Screen({super.key});

  @override
  Widget build(BuildContext context) {

    const primaryColor = Color(0xFF8e44ad);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Use SingleChildScrollView to prevent overflow on small screens
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 80),

              // --- HEADER TEXT ---
              const CustomText(
                'AuraAlert Family Setup',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fromLeft: 0.0,
              ),
              const SizedBox(height: 15),
              CustomText(
                'Connect with your caregivers and family members to share seizure logs and receive important notifications.',
                textAlign: TextAlign.center,
                fontSize: 16,
                color: Colors.grey[600],
                fromLeft: 0.0,
              ),
              const SizedBox(height: 30),

              // --- JOIN EXISTING FAMILY CARD ---
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      'Join Existing Family',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fromLeft: 0.0,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      'Enter the family code shared by your caregiver',
                      fontSize: 14,
                      color: Colors.grey[600],
                      fromLeft: 0.0,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Family Code',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFullWidthButton(
                      text: 'Join Family',
                      onPressed: () {
                        // Navigate to home and clear the signup stack
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MyNavBar()),
                              (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- OR DIVIDER ---
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: CustomText('OR', fontSize: 14, color: Colors.grey[600], fromLeft: 0.0),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 30),

              // --- CREATE NEW FAMILY CARD ---
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      'Create New Family',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fromLeft: 0.0,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      "Don't have a family code? Create your own family group and get a code to share with caregivers and family members.",
                      fontSize: 14,
                      color: Colors.grey[600],
                      fromLeft: 0.0,
                    ),
                    const SizedBox(height: 25),
                    _buildFullWidthButton(
                      text: 'Create New Family',
                      onPressed: () {
                        // Navigate to home and clear the signup stack
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MyNavBar()),
                              (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to create the white card container
  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // Helper widget to create the purple buttons
  Widget _buildFullWidthButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8e44ad),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: CustomText(
        text,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fromLeft: 0.0,
      ),
    );
  }
}