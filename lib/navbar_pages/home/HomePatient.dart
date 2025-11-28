import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // For audio
import 'package:file_picker/file_picker.dart'; // For file upload
import '../../global_widgets/custom_text.dart'; // Your custom text widget

// An enum makes managing the EEG status clean and readable
enum EEGStatus {
  noFile,
  processing,
  seizureDetected,
  noSeizure,
}

class HomePagePatient extends StatefulWidget {
  const HomePagePatient({super.key});

  @override
  State<HomePagePatient> createState() => _HomePagePatientState();
}

class _HomePagePatientState extends State<HomePagePatient> {
  // --- State Variables ---
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundPlaying = false;
  EEGStatus _currentEEGStatus = EEGStatus.noFile;

  @override
  void initState() {
    super.initState();
    // Configure the player to loop the rain sound
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    // Release the audio player resources when the screen is closed
    //The line below is commented,so it will still run when user change pages
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- Logic Functions ---

  void _toggleSound() async {
    if (_isSoundPlaying) {
      await _audioPlayer.stop();
    } else {
      // The path must match what's in your pubspec.yaml and assets folder
      //await _audioPlayer.play(AssetSource('audio/rain.mp3'));
      await _audioPlayer.play(UrlSource('audio/rain.mp3'));

    }
    setState(() {
      _isSoundPlaying = !_isSoundPlaying;
    });
  }

  void _uploadEEGFile() async {
    // Use file_picker to open the file dialog
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // If a file is selected, start the simulated processing
      setState(() {
        _currentEEGStatus = EEGStatus.processing;
      });

      // Simulate a network call or heavy computation
      await Future.delayed(const Duration(seconds: 5));

      // Simulate a result randomly for demonstration
      bool seizureWasDetected = DateTime.now().second % 2 == 0;

      setState(() {
        _currentEEGStatus = seizureWasDetected
            ? EEGStatus.seizureDetected
            : EEGStatus.noSeizure;
      });
    } else {
      // User canceled the picker
      print("File picking was canceled.");
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
              const Spacer(flex: 2), // Add flexible space
              _buildEEGSection(),
              const Spacer(flex: 3), // Add more flexible space
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'Welcome Back, Ahmad', // Placeholder name
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fromLeft: 0,
            ),
            CustomText(
              'Stay calm and safe.',
              fontSize: 16,
              color: Colors.black54,
              fromLeft: 0,
            ),
          ],
        ),
        // Sound toggle button
        IconButton(
          icon: Icon(
            _isSoundPlaying ? Icons.cloudy_snowing: Icons.cloud,
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
          // The upload button
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
          // The status widget, which changes based on _currentEEGStatus
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

  Widget _buildMedicationCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6F6), // A light purple
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
                'Next Reminder: Keppra', // Placeholder drug name
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fromLeft: 0,
              ),
              SizedBox(height: 4),
              CustomText(
                'Dosage: 500mg  |  Time: 9:00 PM', // Placeholder details
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