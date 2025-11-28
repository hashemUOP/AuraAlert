import 'package:flutter/material.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';

// (The enum PatientStatus remains the same)
enum PatientStatus {
  stable,
  warning,
  alert,
}

class HomePageCaregiver extends StatefulWidget {
  const HomePageCaregiver({super.key});

  @override
  State<HomePageCaregiver> createState() => _HomePageCaregiverState();
}

class _HomePageCaregiverState extends State<HomePageCaregiver> {
  PatientStatus _currentStatus = PatientStatus.stable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // decorative purple header
          _buildHeader(),

          // The rest of the content is in an Expanded SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 24),
                    _buildLastAnalysisCard(),
                    const SizedBox(height: 24),
                    _buildLocationCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// --- NEW HEADER WIDGET ---
  /// Builds the purple, curved header at the top of the screen.
  Widget _buildHeader() {
    return ClipPath(
      clipper: CurveClipper(), // This applies our custom curve shape
      child: Container(
        padding: const EdgeInsets.only(top: 50, bottom: 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8e44ad), Color(0xFFa569bd)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: CustomText(
            'Patient Dashboard',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fromLeft: 0,
          ),
        ),
      ),
    );
  }

  // (The _buildStatusCard, _buildLastAnalysisCard, and _buildLocationCard methods
  // remain exactly the same as before. No changes are needed for them.)

  /// 1️⃣ Builds the main status card.
  Widget _buildStatusCard() {
    IconData icon;
    Color cardColor;
    String title;
    String subtitle;
    switch (_currentStatus) {
      case PatientStatus.stable:
        icon = Icons.check_circle; cardColor = Colors.green.shade500; title = 'No Seizure Detected'; subtitle = 'Patient is Stable'; break;
      case PatientStatus.warning:
        icon = Icons.warning; cardColor = Colors.orange.shade500; title = 'Warning: Possible Seizure Detected'; subtitle = 'AI analysis indicates a risk.'; break;
      case PatientStatus.alert:
        icon = Icons.dangerous; cardColor = Colors.red.shade600; title = 'ALERT ACTIVE'; subtitle = 'Last alert was 3 minutes ago'; break;
    }
    return Card(
      elevation: 0, color: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(children: [
          Icon(icon, color: Colors.white, size: 48), const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomText(title, fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fromLeft: 0), const SizedBox(height: 4),
            CustomText(subtitle, fontSize: 16, color: Colors.white70, fromLeft: 0),
          ],),),
        ],),),);
  }

  /// 2️⃣ Builds the card showing a summary of the last analysis.
  Widget _buildLastAnalysisCard() {
    return Card(
      elevation: 2, shadowColor: Colors.grey.withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CustomText('Last Analysis Summary', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fromLeft: 0), const SizedBox(height: 16),
          _buildInfoRow('Time of last analysis:', '11:45 AM, Today'), const Divider(height: 24),
          _buildInfoRow('Result:', 'Stable'), const Divider(height: 24),
          _buildInfoRow('Confidence:', '98.5%'), const Divider(height: 24),
          _buildInfoRow('AI detected:', 'Normal brainwave patterns'),
        ],),),);
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      CustomText(label, fontSize: 15, color: Colors.grey[600], fromLeft: 0),
      CustomText(value, fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black, fromLeft: 0),
    ],);
  }

  /// 3️⃣ Builds the card that simulates the real-time location map.
  Widget _buildLocationCard() {
    return Card(
      elevation: 2, shadowColor: Colors.grey.withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CustomText('Real-time Location', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fromLeft: 0), const SizedBox(height: 16),
          Container(height: 200, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12),),
            child: Stack(alignment: Alignment.center, children: [
              const Icon(Icons.map, color: Colors.grey, size: 100), const Icon(Icons.location_on, color: Colors.red, size: 40),
              Positioned(bottom: 10, left: 10, right: 10, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8),),
                child: const CustomText('123 Health St, Wellness City', textAlign: TextAlign.center, color: Colors.white, fontSize: 14, fromLeft: 0),),)
            ],),)
        ],),),);
  }
}

/// --- NEW CLIPPER CLASS ---
/// This class creates a simple, gentle curve for the bottom of the header.
class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Start from the top-left corner
    path.lineTo(0, size.height - 40); // Go down, leaving 40px for the curve

    // Create a quadratic bezier curve from the bottom-left to the bottom-right
    // The control point in the middle determines the depth of the curve
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 40);

    // Go from the end of the curve to the top-right corner
    path.lineTo(size.width, 0);

    // Close the path to form a shape
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}