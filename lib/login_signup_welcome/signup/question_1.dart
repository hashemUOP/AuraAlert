import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'question_2.dart'; // Import the next screen
import  'package:aura_alert/global_widgets/custom_text.dart';

class Question1Screen extends StatefulWidget {
  const Question1Screen({super.key});

  @override
  State<Question1Screen> createState() => _Question1ScreenState();
}

class _Question1ScreenState extends State<Question1Screen> {
  // this variable will hold the selected option. 1 for the first, 2 for the second.
  // we use `int?` (a nullable int) so it can be null when nothing is selected.
  int? _selectedOption;

  @override
  Widget build(BuildContext context) {
    // we check if an option has been selected to enable/disable the Next button.
    final bool isNextButtonEnabled = _selectedOption != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 35,),
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

            // --- HEADER TEXT ---
            const CustomText(
              'Choose what best describes\nyou',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fromLeft: 0.0,
            ),
            const SizedBox(height: 15),
            CustomText(
              'Select a role to personalize your AuraAlert\nexperience.',
              fontSize: 16,
              color: Colors.grey[600],
              fromLeft: 0.0,
            ),
            const SizedBox(height: 40),

            // --- OPTION 1 ---
            buildOption(
              text: 'I live with epilepsy',
              index: 1,
            ),
            const SizedBox(height: 15),

            // --- OPTION 2 ---
            buildOption(
              text: 'I care for someone with epilepsy',
              index: 0,
            ),

            // this pushes the button to the bottom of the screen
            const Spacer(),

            // --- NEXT BUTTON ---
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ElevatedButton(
                // `onPressed` is null when disabled, which automatically
                // gives it the disabled look and prevents taps.
                  onPressed: isNextButtonEnabled
                      ? () async {
                    await saveUserChoice(_selectedOption!);

                    // load and print the saved data/////////////////////////////
                    final prefs = await SharedPreferences.getInstance();
                    int? choice = prefs.getInt('selectedOption');

                    print("User selected option: $choice");
                    /////////////////////////////////////////////////////////////

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Question2Screen(),
                      ),
                    );
                  }
                      : null,
                style: ElevatedButton.styleFrom(
                  // change color based on whether it's enabled
                  backgroundColor: isNextButtonEnabled
                      ? const Color(0xFF8e44ad)
                      : Colors.grey[300],
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // disable the shadow when the button is disabled
                  elevation: isNextButtonEnabled ? 2 : 0,
                ),
                child: CustomText(
                  "Continue",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  // change text color to be more readable when disabled
                  color: isNextButtonEnabled ? Colors.white : Colors.grey[500],
                  fromLeft: 0.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //function to save the users choice in shared preferences
  Future<void> saveUserChoice(int choice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedOption', choice);
  }


  // A helper widget to avoid repeating the button code
  Widget buildOption({required String text, required int index}) {
    final bool isSelected = _selectedOption == index;

    return GestureDetector(
      onTap: () {
        // `setState` tells Flutter to rebuild the widget with the new selected option
        setState(() {
          _selectedOption = index;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          // change color and border based on selection
          color: isSelected ? const Color(0xFFF0E6F6) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF8e44ad) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: CustomText(
          text,
          fromLeft: 0.0,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isSelected ? const Color(0xFF8e44ad) : Colors.black87,
        ),
      ),
    );
  }
}