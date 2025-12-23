import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../global_widgets/custom_text.dart';

enum PatientStatus {
  stable,
  warning,
  alert,
}

class HomePageCaregiver extends StatefulWidget {
  final String userName;
  const HomePageCaregiver({super.key,required this.userName});

  @override
  State<HomePageCaregiver> createState() => _HomePageCaregiverState();
}

class _HomePageCaregiverState extends State<HomePageCaregiver> {

  String? caregiverEmail;
  PatientStatus _currentStatus = PatientStatus.stable;

  // List to track pending requests for the red dot notification
  List<String> _pendingRequestsList = [];


  @override
  void initState() {
    super.initState();


    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      caregiverEmail = user.email;
      if (kDebugMode) {
        print("Current Caregiver Email initialized: $caregiverEmail");
      }
      // Initial fetch to set the notification dot
      _refreshPendingRequests();
    }
  }

  // Fetch requests where Receiver == ME (The Caregiver)
  Future<void> _refreshPendingRequests() async {
    if (caregiverEmail != null) {
      final reqs = await _getPendingRequests(caregiverEmail!);
      if (mounted) {
        setState(() {
          _pendingRequestsList = reqs;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
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
            'Caregiver Dashboard',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fromLeft: 0,
          ),
        ),
      ),
    );
  }

  // Replaces the simple header with one containing the Notification Bell
  Widget _buildWelcomeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomText('Welcome Back, ${widget.userName}',
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black, fromLeft: 0),
          const CustomText('Your patients need you.',
              fontSize: 16, color: Colors.black54, fromLeft: 0),
        ]),

        // Notification Bell Logic
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Color(0xFF8e44ad), size: 30),
              onPressed: () {
                _refreshPendingRequests().then((_) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: const Text("Patient Requests"),
                              content: _notificationDialogueBody(context, setState),
                              actions: [
                                TextButton(
                                  child: const Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _refreshPendingRequests();
                                  },
                                ),
                              ],
                            );
                          }
                      );
                    },
                  );
                });
              },
            ),
            if (_pendingRequestsList.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // --- NOTIFICATION DIALOG LOGIC ---

  Widget _notificationDialogueBody(BuildContext context, StateSetter setState) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentGeometry.topLeft,
            child: CustomText("Pending Requests:", fromLeft: 0, fontSize: 18),
          ),
          const SizedBox(height: 20),

          FutureBuilder<List<String>>(
            future: _getPendingRequests(caregiverEmail!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading requests"));
              }
              final patients = snapshot.data ?? [];
              if (patients.isEmpty) {
                return const Center(child: Text("No pending requests."));
              }

              return Column(
                children: patients.map((patientEmail) {
                  return _requestRow(patientEmail, screenWidth, setState);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _requestRow(String patientRequestEmail, double screenWidth, StateSetter setState) {
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
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patientRequestEmail, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis,),
                      const CustomText("Patient", fromLeft: 0, fontSize: 11),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // REJECT BUTTON
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 30),
                  onPressed: () async {
                    // Reject logic: Sender is Patient, Receiver is Me (Caregiver)
                    await _rejectPendingRequest(patientRequestEmail, caregiverEmail!);
                    setState(() {});
                  },
                ),
                // ACCEPT BUTTON
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.purple, size: 30),
                  onPressed: () async {
                    await _acceptPendingRequest(patientRequestEmail, caregiverEmail!);
                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- DATA OPERATIONS ---

  // Get requests where Receiver is ME (Caregiver)
  Future<List<String>> _getPendingRequests(String myEmail) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('PendingRequests')
          .where('Receiver', isEqualTo: myEmail)
          .get();

      final senderEmails = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return data['Sender'] as String? ?? '';
      }).where((email) => email.isNotEmpty).toList();

      return senderEmails;
    } catch (e) {
      if (kDebugMode) print("Error getting requests: $e");
      return [];
    }
  }

  // Reject: Delete request where Sender=Patient and Receiver=Me
  Future<void> _rejectPendingRequest(String patientSenderEmail, String meReceiverEmail) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('PendingRequests')
          .where('Sender', isEqualTo: patientSenderEmail)
          .where('Receiver', isEqualTo: meReceiverEmail)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      if (kDebugMode) print("Request rejected.");
    } catch (e) {
      if (kDebugMode) print("Error rejecting request: $e");
    }
  }

  // Accept: Add ME to Patient's Friendship document
  Future<void> _acceptPendingRequest(String patientSenderEmail, String meReceiverEmail) async {
    final firestore = FirebaseFirestore.instance;
    try {
      // 1. Find Friendship doc for the PATIENT
      final friendshipQuery = await firestore
          .collection('Friendship')
          .where('Patient', isEqualTo: patientSenderEmail)
          .limit(1)
          .get();

      if (friendshipQuery.docs.isNotEmpty) {
        // Doc exists: Add me to their caregivers array
        final docRef = friendshipQuery.docs.first.reference;
        await docRef.update({
          'Caregivers': FieldValue.arrayUnion([meReceiverEmail])
        });
      } else {
        // Doc doesn't exist: Create new one for patient
        await firestore.collection('Friendship').add({
          'Patient': patientSenderEmail,
          'Caregivers': [meReceiverEmail],
        });
      }

      // 2. Delete the pending request
      await _rejectPendingRequest(patientSenderEmail, meReceiverEmail);

      if (kDebugMode) print("Request accepted.");
    } catch (e) {
      if (kDebugMode) print("Error accepting request: $e");
    }
  }

  // --- UNCHANGED WIDGETS ---

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

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}