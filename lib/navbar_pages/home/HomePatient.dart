import 'dart:async';
import 'package:aura_alert/REST%20API/flutter_edf_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../global_widgets/custom_text.dart';
import 'HomeCareGiver.dart';

enum EEGStatus {
  noFile,
  processing,
  seizureDetected,
  noSeizure,
}

/// 🔥 Fetch the signed-in user's name from Firestore (UsersInfo collection)
Future<String?> getUserName() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final query = await FirebaseFirestore.instance
        .collection('UsersInfo')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final data = query.docs.first.data();
    return data['name'] as String?;
  } catch (e) {
    print("Error fetching username: $e");
    return null;

  }
}

class HomePagePatient extends StatefulWidget {
  const HomePagePatient({super.key});

  @override
  State<HomePagePatient> createState() => _HomePagePatientState();
}

class _HomePagePatientState extends State<HomePagePatient> {
  // keep your existing implementation (renamed to match button call)
  void _uploadEEGFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      if (mounted) setState(() => _currentEEGStatus = EEGStatus.processing);

      await Future.delayed(const Duration(seconds: 5));
      bool seizureWasDetected = DateTime.now().second % 2 == 0;

      if (mounted) {
        setState(() {
          _currentEEGStatus =
          seizureWasDetected ? EEGStatus.seizureDetected : EEGStatus.noSeizure;
        });
      }
    } else {
      if (kDebugMode) print("File picking was canceled.");
    }
  }

  PatientStatus _currentStatus = PatientStatus.stable;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundPlaying = false;
  EEGStatus _currentEEGStatus = EEGStatus.noFile;
  String? userName = "User"; // Default until loaded

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    loadUserName();
  }

  Future<void> loadUserName() async {
    final name = await getUserName();
    if (mounted) {
      setState(() {
        userName = name ?? "User";
      });
    }
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
        CustomText(label, fontSize: 15, color: Colors.grey[600], fromLeft: 0),
        CustomText(value,
            fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black, fromLeft: 0),
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
          _buildStatusWidget(),
        ],
      ),
    );
  }

  Widget _buildStatusWidget() {
    IconData icon;
    String text;
    Color color;

    switch (_currentEEGStatus) {
      case EEGStatus.noFile:
        icon = Icons.info_outline;
        text = 'No file has been uploaded yet.';
        color = Colors.grey;
        break;
      case EEGStatus.processing:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3)),
            SizedBox(width: 10),
            CustomText('Processing EEG data...', fontSize: 16, color: Colors.blue, fromLeft: 0),
          ],
        );
      case EEGStatus.seizureDetected:
        icon = Icons.warning_amber_rounded;
        text = 'Processing complete. Seizure detected.';
        color = Colors.red;
        break;
      case EEGStatus.noSeizure:
        icon = Icons.check_circle_outline_rounded;
        text = 'Processing complete. No seizure activity found.';
        color = Colors.green;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        CustomText(text, fontSize: 16, color: color, fromLeft: 0),
      ],
    );
  }
}
