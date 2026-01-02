import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CaregiverList extends StatefulWidget {
  const CaregiverList({super.key});

  @override
  State<CaregiverList> createState() => _CaregiverListState();
}

class _CaregiverListState extends State<CaregiverList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? currentCaregiverEmail;

  //declare the stream here so it persists across rebuilds
  late Stream<QuerySnapshot> _friendshipStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      currentCaregiverEmail = user.email;

      // initialize the stream ONCE here.
      // this prevents the StreamBuilder from restarting when you type in the search bar.
      _friendshipStream = FirebaseFirestore.instance
          .collection('Friendship')
          .where('Caregivers', arrayContains: currentCaregiverEmail)
          .snapshots();
    } else {
      // fallback if user is logged out (shouldn't happen in this screen)
      _friendshipStream = const Stream.empty();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // 1. ROOT STREAM: Listen to my current relationships
    return StreamBuilder<QuerySnapshot>(
      stream: _friendshipStream, // FIX: Use the initialized variable
      builder: (context, snapshot) {

        // Handle Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. EXTRACT DATA
        // Get the list of patients I am currently caring for
        List<String> myPatients = [];
        if (snapshot.hasData) {
          myPatients = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['Patient'] as String? ?? '';
          }).where((email) => email.isNotEmpty).toList();
        }

        // 3. SINGLE PATIENT CHECK
        // If myPatients is NOT empty, I already have a patient.
        bool hasPatient = myPatients.isNotEmpty;

        return SingleChildScrollView(
          child: Column(
            children: [
              CustomText(
                "Patient Management",
                fromLeft: 0,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              const SizedBox(height: 20),

              // --- CONDITIONAL SEARCH SECTION ---
              // ONLY show Search Bar if I DO NOT have a patient
              if (!hasPatient) ...[
                Align(
                  alignment: AlignmentGeometry.topLeft,
                  child: CustomText("Add new patient:", fromLeft: 0, fontSize: 18),
                ),
                const SizedBox(height: 20),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                        });
                      },
                    )
                        : null,
                  ),
                ),

                // Search Results (Only if query exists AND we don't have a patient)
                if (_searchQuery.isNotEmpty) _buildSearchResults(screenWidth),
              ] else ...[
                // Optional: Message saying they are full
                Container(
                  width: screenWidth,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: const Text(
                    "You are currently assigned to a patient.\nRemove the current patient to add a new one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.brown),
                  ),
                )
              ],

              const SizedBox(height: 20),
              Align(
                alignment: AlignmentGeometry.topLeft,
                child: CustomText("Current Patient:", fromLeft: 0, fontSize: 18),
              ),
              const SizedBox(height: 20),

              // --- LIST SECTION ---
              // We use the data we already fetched in the Root Stream!
              if (myPatients.isEmpty)
                const Center(child: Text("No patients found."))
              else
                Column(
                  children: myPatients.map((patientEmail) {
                    return _patientsRow(
                      targetPatientEmail: patientEmail,
                      currentCaregiverEmail: currentCaregiverEmail!,
                      screenWidth: screenWidth,
                      context: context,
                      // No need for setState() here because the StreamBuilder
                      // will automatically rebuild when the document is deleted!
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- SEARCH RESULTS WIDGET ---
  Widget _buildSearchResults(double screenWidth) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('UsersInfo')
          .where('isPatient', isEqualTo: true)
          .where('email', isGreaterThanOrEqualTo: _searchQuery)
          .where('email', isLessThan: '$_searchQuery\uf8ff') // Optimized query
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (kDebugMode) print("Error: ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        // We don't need to filter existing patients here because
        // this widget is HIDDEN if we have a patient.
        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("No new patients found with that email."),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.grey.withOpacity(0.05),
          child: Column(
            children: docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              String resultEmail = data['email'] ?? 'No Email';

              return _searchRow(
                targetUserEmail: resultEmail,
                currentSenderEmail: currentCaregiverEmail!,
                screenWidth: screenWidth,
                context: context,
                onSuccess: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = "";
                  });
                  FocusScope.of(context).unfocus();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // --- ROW FOR CURRENT PATIENT ---
  Widget _patientsRow({
    required String targetPatientEmail,
    required String currentCaregiverEmail,
    required double screenWidth,
    required BuildContext context,
  }) {
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
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(targetPatientEmail, fromLeft: 0, fontSize: 16,),
                    CustomText("Patient", fromLeft: 0, fontSize: 11),
                  ],
                ),
              ],
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text("Remove Patient"),
                      content: Text("Are you sure you want to stop caring for $targetPatientEmail?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                        TextButton(
                          child: const Text("Yes", style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await _removePatient(context, targetPatientEmail, currentCaregiverEmail);
                            // StreamBuilder handles the UI update automatically
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.favorite, color: Colors.pink, size: 30.0),
            ),
          ],
        ),
      ),
    );
  }

  // --- ROW FOR SEARCH RESULT ---
  // --- ROW FOR SEARCH RESULT ---
  Widget _searchRow({
    required String targetUserEmail,
    required String currentSenderEmail,
    required double screenWidth,
    required BuildContext context,
    required VoidCallback onSuccess,
  }) {
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
        // ✅ FIX: Removed nested Row, used Expanded for the middle part
        child: Row(
          children: [
            const Icon(Icons.person, color: Colors.purple, size: 34.0),
            const SizedBox(width: 20),

            // ✅ FIX: Expanded forces the Column to take only available space
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    targetUserEmail,
                    overflow: TextOverflow.ellipsis, // Now this works!
                    maxLines: 1,
                    style: const TextStyle(fontSize: 16),
                  ),
                  CustomText("Patient", fromLeft: 0, fontSize: 11),
                ],
              ),
            ),
            const SizedBox(width: 10), // Spacing before the action button

            // Check for Pending Request
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('PendingRequests')
                  .where('Sender', isEqualTo: currentSenderEmail)
                  .where('Receiver', isEqualTo: targetUserEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(width: 30, height: 30);
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      "Pending",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () async {
                    try {
                      await addPendingRequest(
                        senderEmail: currentSenderEmail,
                        receiverEmail: targetUserEmail,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Request sent to $targetUserEmail'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      onSuccess();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString().replaceAll("Exception: ", "")),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Icon(Icons.add, color: Colors.pink, size: 30.0),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---
  Future<void> addPendingRequest({
    required String senderEmail,
    required String receiverEmail,
  }) async {
    final QuerySnapshot existingRequests = await FirebaseFirestore.instance
        .collection('PendingRequests')
        .where('Sender', isEqualTo: senderEmail)
        .where('Receiver', isEqualTo: receiverEmail)
        .limit(1)
        .get();

    if (existingRequests.docs.isNotEmpty) {
      throw 'Request already pending with this user.';
    }

    try {
      await FirebaseFirestore.instance.collection('PendingRequests').add({
        'Date': Timestamp.now(),
        'Sender': senderEmail,
        'Receiver': receiverEmail,
        'Type': 'From Caregiver To Patient',
        'isSenderPatient': false,
      });
    } catch (e) {
      throw Exception('Failed to add pending request: $e');
    }
  }

  Future<void> _removePatient(BuildContext context, String targetPatientEmail, String myselfEmail) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Friendship')
          .where('Patient', isEqualTo: targetPatientEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;
        await docRef.update({
          'Caregivers': FieldValue.arrayRemove([myselfEmail])
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient removed successfully'), backgroundColor: Colors.purple),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Relationship not found')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing patient: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}