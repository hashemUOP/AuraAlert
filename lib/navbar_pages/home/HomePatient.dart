import 'dart:async';
import 'package:aura_alert/REST%20API/flutter_edf_parser.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../global_widgets/custom_text.dart';
import 'HomeCareGiver.dart';



class HomePagePatient extends StatefulWidget {
  const HomePagePatient({super.key});

  @override
  State<HomePagePatient> createState() => _HomePagePatientState();
}

class _HomePagePatientState extends State<HomePagePatient> {

  String userName = "User";//nullable default name

  PatientStatus _currentStatus = PatientStatus.stable;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _loadUserName();
  }

  /// Reads the 'user_name' from SharedPreferences that is initialized in main.dart
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "User";
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleSound() async {
    if (_isSoundPlaying) {
      await _audioPlayer.stop();
    } else {
      // If this is an asset, use AssetSource('audio/rain.mp3') instead of UrlSource
      await _audioPlayer.play(UrlSource('audio/rain.mp3'));
    }
    if (mounted) {
      setState(() {
        _isSoundPlaying = !_isSoundPlaying;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. The Header stays fixed at the top
            _buildHeader(),

            // 2. WRAP THIS IN EXPANDED
            // This forces the scroll view to take only the remaining space
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader2(),
                      const SizedBox(height: 24),
                      _buildStatusCard(),
                      const SizedBox(height: 24),
                      _buildLastAnalysisCard(),
                      const SizedBox(height: 24),
                      _buildEEGSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI builder methods unchanged except minor spacing fixes ---
  Widget _buildLastAnalysisCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText('Last Analysis Summary',
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fromLeft: 0),
            const SizedBox(height: 16),
            _buildInfoRow('Time of last analysis:', '11:45 AM, Today'),
            const Divider(height: 24),
            _buildInfoRow('Result:', 'Stable'),
            const Divider(height: 24),
            _buildInfoRow('Confidence:', '98.5%'),
            const Divider(height: 24),
            _buildInfoRow('AI detected:', 'Normal brainwave patterns'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Wrap the first text if it might get long
        Flexible(
          flex: 1,
          child: CustomText(label, fontSize: 15, color: Colors.grey[600], fromLeft: 0),
        ),
        const SizedBox(width: 10), // Add a little spacing between them
        // Wrap the second text so it pushes to the left or wraps
        Flexible(
          flex: 2, // Give the value slightly more space priority
          child: CustomText(value,
              fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black, fromLeft: 0),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    IconData icon;
    Color cardColor;
    String title;
    String subtitle;
    switch (_currentStatus) {
      case PatientStatus.stable:
        icon = Icons.check_circle;
        cardColor = Colors.green.shade500;
        title = 'No Seizure Detected';
        subtitle = 'Patient is Stable';
        break;
      case PatientStatus.warning:
        icon = Icons.warning;
        cardColor = Colors.orange.shade500;
        title = 'Warning: Possible Seizure Detected';
        subtitle = 'AI analysis indicates a risk.';
        break;
      case PatientStatus.alert:
        icon = Icons.dangerous;
        cardColor = Colors.red.shade600;
        title = 'ALERT ACTIVE';
        subtitle = 'Last alert was 3 minutes ago';
        break;
    }
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomText(title,
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fromLeft: 0),
                const SizedBox(height: 4),
                CustomText(subtitle, fontSize: 16, color: Colors.white70, fromLeft: 0),
              ]),
            ),
          ],
        ),
      ),
    );
  }

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
  Widget _buildHeader2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomText('Welcome Back, $userName',
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black, fromLeft: 0),
          const CustomText('Stay calm and safe.',
              fontSize: 16, color: Colors.black54, fromLeft: 0),
        ]),
      ],
    );
  }

  Widget _buildEEGSection() {
    return Center(
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: ()async =>await pickAndUploadFile(),
            icon: const Icon(Icons.upload_file, color: Colors.white),
            label: const CustomText('Upload EEG Data',
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fromLeft: 0),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8e44ad),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
