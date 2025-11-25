import 'package:aura_alert/login_signup_welcome/signup/question_6.dart';
import 'package:flutter/material.dart';
import  'package:aura_alert/global_widgets/custom_text.dart';

class Question5Screen extends StatelessWidget {
  const Question5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
          child:Padding(
              padding:const EdgeInsets.symmetric(horizontal: 25.0),
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
                        const SizedBox(width: 48), // To balance the IconButton
                      ],
                    ),
                    const SizedBox(height: 50),

                    CustomText(
                      'Welcome to your AuraAlert family',
                      fromLeft: 0.0,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 60),
                    CustomText(
                      'AuraAlert groups you in a family with your loved ones and caregivers so you can manage epilepsy as a team.',
                      textAlign: TextAlign.center,
                      fontSize: 18,
                      color: Colors.grey[700],
                      fromLeft: 0.0,
                    ),
                    const SizedBox(height: 30),

                    // --- ILLUSTRATION ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'images/family.jpg',
                        height: 200,
                      ),
                    ),

                    const SizedBox(height: 20,),
                    // --- CONTINUE BUTTON ---
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Question6Screen()),
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



                  ]
        ),
          ),
      ),
    );
  }
}