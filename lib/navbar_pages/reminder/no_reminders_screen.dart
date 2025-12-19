import 'package:flutter/material.dart';
import 'package:aura_alert/navbar_pages/reminder/create_reminder.dart';

class NoRemindersScreen extends StatelessWidget {
  const NoRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        children: [
          SizedBox(height: screenHeight*0.15,),
          Image.asset(
            "assets/images/icons8-clock-375.png",
            width: screenWidth * 0.17,
          ),
          const SizedBox(height: 20),
          const Text(
            "You Have No Reminders",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Add your first reminder.",
            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 14,color: Colors.grey.shade600),
            textAlign: TextAlign.center, // Centers the multi-line text
          ),
          const SizedBox(height: 30), // Space between text and button
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateReminder()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.purple[300], // Background color for the button
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Add Reminder",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
      ),
    );
  }
}