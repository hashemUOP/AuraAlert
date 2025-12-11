import 'package:flutter/material.dart';
// Import the package we just added
import 'package:url_launcher/url_launcher.dart';
import '../../global_widgets/custom_text.dart';

class EmergencyGuidePage extends StatelessWidget {
  const EmergencyGuidePage({super.key});

  // This function will launch the phone's dialer with the emergency number.
  void _callEmergencyServices() async {
    // We use Uri.parse for safety. 'tel:' is the command to open the dialer.
    final Uri emergencyCallUri = Uri.parse('tel:911'); // Use your country's emergency number

    // 'canLaunchUrl' checks if the device can handle this action (e.g., has a dialer).
    if (await canLaunchUrl(emergencyCallUri)) {
      await launchUrl(emergencyCallUri);
    } else {
      // This is a fallback for devices that can't make calls (like a tablet or simulator).
      print("Could not launch the emergency call.");
      // In a real app, you might show a pop-up message to the user here.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergency Guide',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _callEmergencyServices,
        label: const Text('Call Emergency',style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.call,color: Colors.white,),
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION: Advice for the Patient ---
              _buildSectionHeader('Advice for Patients (Self-Care)', Colors.blue[700]!),
              _buildStepItem(
                icon: Icons.bedtime,
                text: 'Prioritize Sleep: Aim for 7-9 hours of consistent sleep each night.',
                color: Colors.blue[700]!,
              ),
               _buildStepItem(
                icon: Icons.medical_services,
                text: 'Take Medication on Time: Never miss a dose. Use alarms or our app\'s reminders.',
                color: Colors.blue[700]!,
              ),
              _buildStepItem(
                icon: Icons.no_drinks,
                text: 'Avoid Triggers: Be aware of your personal triggers, such as flashing lights, stress, or alcohol.',
                color: Colors.blue[700]!,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // --- Section for Caregivers (First Aid) ---
              _buildSectionHeader('First Aid for Caregivers (The "3 S\'s")', Colors.green[700]!),
              _buildStepItem(
                icon: Icons.safety_check,
                text: 'Stay Safe: Guide the person gently to the floor and clear the area of hard or sharp objects.',
                color: Colors.green[700]!,
              ),
              _buildStepItem(
                icon: Icons.support,
                text: 'Side Position: Gently roll the person onto one side to help them breathe.',
                color: Colors.green[700]!,
              ),
              _buildStepItem(
                icon: Icons.shield_outlined,
                text: 'Soft Headrest: Place something soft and flat, like a folded jacket, under their head.',
                color: Colors.green[700]!,
              ),
              const SizedBox(height: 24),

              // --- "What NOT to Do" Section (unchanged) ---
              _buildSectionHeader('What NOT to Do', Colors.red[700]!),
               _buildStepItem(
                icon: Icons.pan_tool_outlined,
                text: 'Do NOT hold them down or try to stop their movements.',
                color: Colors.red[700]!,
              ),
              _buildStepItem(
                icon: Icons.no_food_outlined,
                text: 'Do NOT put anything in their mouth. This can cause injury.',
                color: Colors.red[700]!,
              ),
              const SizedBox(height: 24),

              // --- "When to Call" Section (unchanged) ---
              _buildSectionHeader('Call Emergency Services If...', Colors.orange[800]!),
              _buildStepItem(
                icon: Icons.more_time,
                text: 'The seizure lasts longer than 5 minutes.',
                color: Colors.orange[800]!,
              ),
               _buildStepItem(
                icon: Icons.replay_outlined,
                text: 'A second seizure starts soon after the first.',
                color: Colors.orange[800]!,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widgets remain the same
  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: CustomText(
        title,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
        fromLeft: 0,
      ),
    );
  }

  Widget _buildStepItem({required IconData icon, required String text, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: CustomText(
              text,
              fontSize: 16,
              color: Colors.black87,
              fromLeft: 0,
            ),
          ),
        ],
      ),
    );
  }
}