import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyGuidePage extends StatelessWidget {
  const EmergencyGuidePage({super.key});

  void _callEmergencyServices() async {
    final Uri emergencyCallUri = Uri.parse('tel:911');

    if (await canLaunchUrl(emergencyCallUri)) {
      await launchUrl(emergencyCallUri);
    } else {
      if (kDebugMode) {
        print("Could not launch the emergency call.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergency Guide', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _callEmergencyServices,
        label: const Text('Call Emergency', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.call, color: Colors.white),
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

  // ✅ UPDATED: Used standard 'Text' widget to ensure wrapping for Titles
  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // ✅ UPDATED: Used standard 'Text' widget to ensure wrapping for descriptions
  Widget _buildStepItem({required IconData icon, required String text, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              // By default, standard Text wraps.
              // If you ever need to force it, you can add: softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}