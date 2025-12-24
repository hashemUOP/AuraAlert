import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../global_widgets/custom_text.dart';
import 'HomeCareGiver.dart';

class HomePagePatient extends StatefulWidget {
  final String userName;
  const HomePagePatient({super.key, required this.userName});

  @override
  State<HomePagePatient> createState() => _HomePagePatientState();
}

class _HomePagePatientState extends State<HomePagePatient> {
  //show loading bool for EDF send,receive
  bool uploadingLoading = false;
  bool isSuccess = false;

  //define variables for the last test results
  String? aiDetected;
  String? analysisTime;
  String? confidence;
  String? result;
  String? patientEmail;
  bool? seizureAlert;

  PatientStatus _currentStatus = PatientStatus.stable;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundPlaying = false;

  // To update the red dot on notification icon
  List<String> _pendingRequestsList = [];

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    //read user (patient) email
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      patientEmail = user.email;
      if (kDebugMode) {
        print("Current User Email initialized: $patientEmail");
      }
      // load the pending requests for patient
      _refreshPendingRequests();

      // load last test result for patient
      _loadPatientLastResult();
    }
  }

  Future<void> _refreshPendingRequests() async {
    if (patientEmail != null) {
      final reqs = await _getPendingRequests(patientEmail!);
      if (mounted) {
        setState(() {
          _pendingRequestsList = reqs;
        });
      }
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
      await _audioPlayer.play(UrlSource('audio/rain.mp3'));
    }
    if (mounted) {
      setState(() {
        _isSoundPlaying = !_isSoundPlaying;
      });
    }
  }

  // --- uploading EDF file sending it to server via REST API ---
  Future<void> pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['edf'],
      withData: true,
    );

    if (result == null) return;

    // Reset success state if we pick a new file
    setState(() {
      isSuccess = false;
      uploadingLoading = true;
    });

    final file = result.files.single;
    final bytes = file.bytes;
    final filename = file.name;

    try {
      final uri = Uri.parse('http://127.0.0.1:8000/api/data/predict/');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes!,
            filename: filename,
            contentType: MediaType('application', 'octet-stream'),
          ),
        );
      request.headers['Accept'] = 'application/json';

      final streamed = await request.send();

      // Switch to processing state
      setState(() {
        uploadingLoading = false;
      });

      final resp = await http.Response.fromStream(streamed);


      // the resp body must be converted for it's to be accessed
      final Map<String, dynamic> responseData = jsonDecode(resp.body);

      if (mounted) {
        setState(() {
          isSuccess = true; // response from server arrived update state
        });
      }

      if (kDebugMode) {
        print('Status: ${resp.statusCode}');
        print('Parsed Data: $responseData');
      }

      // ---  save test results to firebase ---
      if (patientEmail != null) {
        await _createOrUpdatePatientLastResult(
          responseData['ai_detected'] ?? "Unknown",
          responseData['analysis_time'] ?? DateTime.now().toString(),
          responseData['confidence'].toString(),
          responseData['result'] ?? "Unknown",
          patientEmail!,
          responseData['seizure_alert'] ?? false,
        );
      }

      // delay 1 seconds so user can read "All done!"
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          isSuccess = false; // hide the loading box
        });
      }
    } catch (e) {
      setState(() {
        uploadingLoading = false;
        isSuccess = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Helper boolean to check if we should show the overlay
    bool showOverlay = uploadingLoading || isSuccess;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // --- MAIN CONTENT ---
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          _buildHeader2(_pendingRequestsList),
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

            // --- BLACK DIMMER ---
            Visibility(
              visible: showOverlay,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.7),
              ),
            ),

            // --- LOADING / STATUS BOX ---
            Visibility(
              visible: showOverlay,
              child: Center(
                child: Container(
                  width: screenWidth * 0.7,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Only show spinner if we are NOT in success state
                        if (!isSuccess) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.purple,
                              ),
                              const SizedBox(width: 20),
                              CustomText(
                                "Just a moment...",
                                fromLeft: 0,
                                fontSize: 18,
                              ),
                            ],
                          ),
                        ] else ...[
                          // Show Checkmark when done
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 50,
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Text Logic
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: CustomText(
                            color: Colors.purple,
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                            uploadingLoading
                                ? "Please wait while our AI reviews your data..."
                                : "All done! Here are your results.",
                            fromLeft: 0,
                            textAlign: TextAlign.center,
                          ),
                        ),
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

  Future<void> _createOrUpdatePatientLastResult(
      String aiDetected,
      String analysisTime,
      String confidence,
      String result,
      String patientEmail,
      bool seizureAlert,
      ) async {
    try {
      final CollectionReference collection =
      FirebaseFirestore.instance.collection('LastAnalysis');

      // 1. Check if user has previous results
      final QuerySnapshot querySnapshot = await collection
          .where('patient', isEqualTo: patientEmail)
          .limit(1)
          .get();

      // Prepare the data map (analysis_time is now stored as String)
      final Map<String, dynamic> data = {
        'ai_detected': aiDetected,
        'analysis_time': analysisTime,
        'confidence': confidence,
        'patient': patientEmail,
        'result': result,
        'seizure_alert': seizureAlert,
      };

      if (querySnapshot.docs.isNotEmpty) {
        // UPDATE existing document
        final DocumentReference docRef = querySnapshot.docs.first.reference;
        await docRef.update(data);
        if (kDebugMode) print("Existing analysis record updated for $patientEmail");
      } else {
        // CREATE new document
        await collection.add(data);
        if (kDebugMode) print("New analysis record created for $patientEmail");
      }

      // 2. REFRESH UI IMMEDIATELY
      // We update the local variables inside setState so the screen changes now.
      if (mounted) {
        setState(() {
          this.aiDetected = aiDetected;
          this.analysisTime = analysisTime;
          this.confidence = confidence;
          this.result = result;
          this.seizureAlert = seizureAlert;

          // update the status card logic instantly
          if (result == "Seizure" || seizureAlert == true) {
            _currentStatus = PatientStatus.alert;
          } else {
            _currentStatus = PatientStatus.stable;
          }
        });
      }
    } catch (e) {
      if (kDebugMode) print("Error updating LastAnalysis: $e");
    }
  }
  Future<Map<String, dynamic>> _getPatientLastTestResult(String patientEmail) async {
    // Default map with "empty" values
    final Map<String, dynamic> defaultData = {
      'ai_detected': '-',
      'analysis_time': null, // Kept null so UI can check before formatting
      'confidence': '-',
      'result': '-',
      'seizure_alert': false, // Boolean default
    };

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('LastAnalysis')
          .where('patient', isEqualTo: patientEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Data found: Return the actual data from Firestore
        return querySnapshot.docs.first.data();
      } else {
        // No data found: Return the default "-" map
        return defaultData;
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching last result: $e");
      // On error, return default map to prevent app crash
      return defaultData;
    }
  }


  Widget _buildHeader() {
    return ClipPath(
      clipper: CurveClipper(),
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

  Widget _buildHeader2(List<String> requests) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'Welcome Back, ${widget.userName}',
              fontSize: 18,
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
        Row(
          children: [
            IconButton(
              icon: Icon(
                _isSoundPlaying ? Icons.cloudy_snowing : Icons.cloud_outlined,
                color: const Color(0xFF8e44ad),
                size: 30,
              ),
              onPressed: _toggleSound,
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Color(0xFF8e44ad),
                    size: 30,
                  ),
                  onPressed: () {
                    // Refresh data before showing dialog
                    _refreshPendingRequests().then((_) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            // Use StatefulBuilder to update dialog state
                            builder: (context, setState) {
                              return AlertDialog(
                                title: const Text("Notifications"),
                                content: _notificationDialogueBody(
                                  context,
                                  setState,
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Close"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      // Refresh main screen state when closing dialog
                                      _refreshPendingRequests();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    });
                  },
                ),
                if (requests.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _notificationDialogueBody(BuildContext context, StateSetter setState) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for dialogs
        children: [
          Align(
            alignment: AlignmentGeometry.topLeft,
            child: CustomText("Pending Requests:", fromLeft: 0, fontSize: 18),
          ),
          const SizedBox(height: 20),

          FutureBuilder<List<String>>(
            future: _getPendingRequests(patientEmail!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading requests"));
              }
              final caregivers = snapshot.data ?? [];
              if (caregivers.isEmpty) {
                return const Center(child: Text("No pending requests."));
              }

              return Column(
                children: caregivers.map((email) {
                  // PASS THE SPECIFIC CAREGIVER EMAIL HERE
                  return _requestRow(email, screenWidth, setState);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // Updated to accept setState to refresh the dialog
  Widget _requestRow(
    String caregiverEmail,
    double screenWidth,
    StateSetter setState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: 70,
        width: screenWidth * 0.99,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey.shade100,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.purple, size: 34.0),
                const SizedBox(width: 10),
                SizedBox(
                  width: 100, // Limit width so email doesn't overflow
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caregiverEmail,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const CustomText("Caregiver", fromLeft: 0, fontSize: 11),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 30),
                  onPressed: () async {
                    await _rejectPendingRequest(patientEmail!, caregiverEmail);
                    setState(() {}); // Refresh the dialog UI
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.purple, size: 30),
                  onPressed: () async {
                    await _acceptPendingRequest(patientEmail!, caregiverEmail);
                    setState(() {}); // Refresh the dialog UI
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _loadPatientLastResult() async {
    if (patientEmail == null) return;

    // call helper function that returns a map of patients last test data
    final data = await _getPatientLastTestResult(patientEmail!);

    if (mounted) {
      setState(() {
        // Update Strings (using toString() ensures safety if null)
        aiDetected = data['ai_detected']?.toString() ?? "-";
        confidence = data['confidence']?.toString() ?? "-";
        result = data['result']?.toString() ?? "-";

        // Update Boolean
        seizureAlert = data['seizure_alert'] is bool
            ? data['seizure_alert']
            : false;

        // Update DateTime (Handle Firestore Timestamp conversion)
        if (data['analysis_time'] != null) {
          analysisTime = data['analysis_time'];
        } else {
          analysisTime = null;
        }

        // update your status card based on this result immediately
        if (result == "Seizure" || seizureAlert == true) {
          _currentStatus = PatientStatus.alert;
        } else {
          _currentStatus = PatientStatus.stable;
        }
      });
    }
  }

  // --- DATA LOGIC ---
  Future<List<String>> _getPendingRequests(String patientEmail) async {
    try {
      // FIX: Query where Receiver is ME (the patient)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('PendingRequests')
          .where('Receiver', isEqualTo: patientEmail)
          .get();

      final senderEmails = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return data['Sender'] as String? ?? '';
          })
          .where((email) => email.isNotEmpty)
          .toList();

      return senderEmails;
    } catch (e) {
      if (kDebugMode) print("Error getting requests: $e");
      return [];
    }
  }

  Future<void> _rejectPendingRequest(
    String patientEmail,
    String caregiverEmail,
  ) async {
    try {
      // FIX: Match BOTH Receiver and Sender to delete specific request
      final querySnapshot = await FirebaseFirestore.instance
          .collection('PendingRequests')
          .where('Receiver', isEqualTo: patientEmail)
          .where('Sender', isEqualTo: caregiverEmail)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      if (kDebugMode) print("Request rejected.");
    } catch (e) {
      if (kDebugMode) print("Error rejecting request: $e");
    }
  }

  Future<void> _acceptPendingRequest(
    String patientEmail,
    String caregiverEmail,
  ) async {
    final firestore = FirebaseFirestore.instance;
    try {
      final friendshipQuery = await firestore
          .collection('Friendship')
          .where('Patient', isEqualTo: patientEmail)
          .limit(1)
          .get();

      if (friendshipQuery.docs.isNotEmpty) {
        final docRef = friendshipQuery.docs.first.reference;
        await docRef.update({
          'Caregivers': FieldValue.arrayUnion([caregiverEmail]),
        });
      } else {
        await firestore.collection('Friendship').add({
          'Patient': patientEmail,
          'Caregivers': [caregiverEmail],
        });
      }

      // Delete the request after accepting
      await _rejectPendingRequest(patientEmail, caregiverEmail);

      if (kDebugMode) print("Request accepted.");
    } catch (e) {
      if (kDebugMode) print("Error accepting request: $e");
    }
  }

  // --- UNCHANGED WIDGETS ---

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
            const CustomText(
              'Last Analysis Summary',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fromLeft: 0,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Time of last analysis:', analysisTime.toString()),
            const Divider(height: 24),
            _buildInfoRow('Result:', result ??"-"),
            const Divider(height: 24),
            _buildInfoRow('Confidence:',confidence ?? "-"),
            const Divider(height: 24),
            _buildInfoRow('AI detected:', aiDetected ?? "-"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: CustomText(
            label,
            fontSize: 15,
            color: Colors.grey[600],
            fromLeft: 0,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 2,
          child: CustomText(
            value,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fromLeft: 0,
          ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    title,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fromLeft: 0,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    subtitle,
                    fontSize: 16,
                    color: Colors.white70,
                    fromLeft: 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEEGSection() {
    return Center(
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () async => await pickAndUploadFile(),
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
        ],
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height,
    );
    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
