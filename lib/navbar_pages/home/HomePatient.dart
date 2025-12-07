import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../global_widgets/custom_text.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundPlaying = false;
  EEGStatus _currentEEGStatus = EEGStatus.noFile;

  String? userName = "User"; // Default until loaded

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    loadUserName(); // Load Firestore name safely
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

  // --- Logic Functions ---
  void _toggleSound() async {
    if (_isSoundPlaying) {
      await _audioPlayer.stop();
    } else {
      await _audioPlayer.play(UrlSource('audio/rain.mp3'));
    }
    setState(() {
      _isSoundPlaying = !_isSoundPlaying;
    });
  }

  void _uploadEEGFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _currentEEGStatus = EEGStatus.processing;
      });

      await Future.delayed(const Duration(seconds: 5));

      bool seizureWasDetected = DateTime.now().second % 2 == 0;

      setState(() {
        _currentEEGStatus = seizureWasDetected
            ? EEGStatus.seizureDetected
            : EEGStatus.noSeizure;
      });
    } else {
      if (kDebugMode) {
        print("File picking was canceled.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const Spacer(flex: 2),
              _buildEEGSection(),
              const Spacer(flex: 3),
              _buildMedicationCard(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Builder Widgets ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'Welcome Back, $userName',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fromLeft: 0,
            ),
            const CustomText(
              'Stay calm and safe.',
              fontSize: 16,
              color: Colors.black54,
              fromLeft: 0,
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            _isSoundPlaying ? Icons.cloudy_snowing : Icons.cloud,
            color: const Color(0xFF8e44ad),
            size: 30,
          ),
          onPressed: _toggleSound,
        ),
      ],
    );
  }

  Widget _buildEEGSection() {
    return Center(
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _uploadEEGFile,
            icon: const Icon(Icons.upload_file, color: Colors.white),
            label: const CustomText(
              'Upload EEG Data',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fromLeft: 0,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8e44ad),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 3)),
            SizedBox(width: 10),
            CustomText(
              'Processing EEG data...',
              fontSize: 16,
              color: Colors.blue,
              fromLeft: 0,
            ),
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

  Widget _buildMedicationCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.medication, color: Color(0xFF8e44ad), size: 40),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'Next Reminder: Keppra',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fromLeft: 0,
              ),
              SizedBox(height: 4),
              CustomText(
                'Dosage: 500mg  |  Time: 9:00 PM',
                fontSize: 14,
                color: Colors.black54,
                fromLeft: 0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
