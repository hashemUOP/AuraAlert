import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PatientList extends StatefulWidget {
  const PatientList({super.key});

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ""; // variable to keep track of what the user types

  String? patientEmail;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // get the current user and save their email when page starts
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      patientEmail = user.email;
      if (kDebugMode) {
        print("Current User Email initialized: $patientEmail");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return SingleChildScrollView(
      child: Column(
        children: [
          CustomText(
            "Caregivers Management",
            fromLeft: 0,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          SizedBox(height: 20),
          Align(
            alignment: AlignmentGeometry.topLeft,
            child: CustomText("Add new caregiver:", fromLeft: 0, fontSize: 18),
          ),
          SizedBox(height: 20),

          // --- SEARCH BAR ---
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by email...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey),
              ),
              // Add clear button when text exists
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear),
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

          // --- ACCORDION / SEARCH RESULTS ---
          // Only show this section if the user has typed something
          if (_searchQuery.isNotEmpty)
            _buildSearchResults(screenWidth),

          SizedBox(height: 20),
          Align(
            alignment: AlignmentGeometry.topLeft,
            child: CustomText("Current Members:", fromLeft: 0, fontSize: 18),
          ),
          SizedBox(height: 20),

          // list all patients caregivers
          FutureBuilder<List<String>>(
            future: _getListOfMembers(patientEmail!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading caregivers"));
              }

              final caregivers = snapshot.data ?? [];

              if (caregivers.isEmpty) {
                return const Center(child: Text("No caregivers found."));
              }

              return SingleChildScrollView(
                child: Column(
                  children: caregivers.map((caregiverEmail) {
                    return _caregiversRow(
                      caregiverEmail: caregiverEmail,
                      patientEmail: patientEmail!,
                      screenWidth: screenWidth,
                      context: context,
                      onDeleteSuccess: () {
                        // this triggers the FutureBuilder to run again
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          // SizedBox(height: 20),
          // Align(
          //   alignment: AlignmentGeometry.topLeft,
          //   child: CustomText("Pending Requests:", fromLeft: 0, fontSize: 18),
          // ),
          // SizedBox(height: 20),
          //
          // // list all patients pending requests
          // FutureBuilder<List<String>>(
          //   // call the function defined under to get data
          //   future: _getPendingRequests(patientEmail!),
          //   builder: (context, snapshot) {
          //     // 1. Loading State
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const Center(child: CircularProgressIndicator());
          //     }
          //
          //     // 2. Error State
          //     if (snapshot.hasError) {
          //       return const Center(child: Text("Error loading caregivers"));
          //     }
          //
          //     // 3. Data Loaded
          //     final caregivers = snapshot.data ?? [];
          //
          //     if (caregivers.isEmpty) {
          //       return const Center(child: Text("No caregivers found."));
          //     }
          //
          //     // 4. The Scrollable List
          //     return SingleChildScrollView(
          //       child: Column(
          //         children: caregivers.map((email) {
          //           return _requestRow(email, screenWidth);
          //         }).toList(),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  // --- FIRESTORE QUERY FUNCTION ---
  Widget _buildSearchResults(double screenWidth) {
    // 1. First Stream: Listen to Friendship to know who to HIDE
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Friendship')
          .where('Patient', isEqualTo: patientEmail)
          .snapshots(),
      builder: (context, friendshipSnapshot) {

        // Get the list of emails to hide (Current Caregivers)
        List<String> existingCaregivers = [];
        if (friendshipSnapshot.hasData && friendshipSnapshot.data!.docs.isNotEmpty) {
          final data = friendshipSnapshot.data!.docs.first.data() as Map<String, dynamic>;
          if (data.containsKey('Caregivers') && data['Caregivers'] != null) {
            existingCaregivers = List<String>.from(data['Caregivers']);
          }
        }

        // 2. Second Stream: Perform the Search
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('UsersInfo')
              .where('isPatient', isEqualTo: false)
              .where('email', isGreaterThanOrEqualTo: _searchQuery)
              .where('email', isLessThan: _searchQuery + 'z')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("No user found."),
              );
            }

            // 3. FILTERING: Remove users who are already caregivers
            final filteredDocs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final email = data['email'];
              // Only keep if NOT in existing list
              return !existingCaregivers.contains(email);
            }).toList();

            if (filteredDocs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("User is already added."),
              );
            }

            // 4. Render the remaining results
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.grey.withOpacity(0.05),
              child: Column(
                children: filteredDocs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  String userEmail = data['email'] ?? 'No Email';

                  return _searchRow(
                    userEmail: userEmail,
                    patientEmail: patientEmail!,
                    screenWidth: screenWidth,
                    context: context,
                    onSuccess: () {
                      _searchController.clear();
                      setState(() { _searchQuery = ""; });
                      FocusScope.of(context).unfocus();
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _caregiversRow({
    required String caregiverEmail,
    required String patientEmail,
    required double screenWidth,
    required BuildContext context,
    required VoidCallback onDeleteSuccess,
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
                    CustomText(caregiverEmail, fromLeft: 0, fontSize: 16),
                    CustomText("Caregiver", fromLeft: 0, fontSize: 11),
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
                      title: const Text("Remove Caregiver"),
                      content: Text(
                          "Are you sure you want to remove $caregiverEmail?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                        TextButton(
                          child: const Text(
                              "Yes", style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            // 1. Close the dialog first
                            Navigator.of(dialogContext).pop();

                            // 2. Call the delete function using the passed variables
                            await _removeCaregiver(
                                context, caregiverEmail, patientEmail);

                            // 3. Refresh the UI
                            onDeleteSuccess();
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


  Widget _searchRow({
    required String userEmail,
    required String patientEmail,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- 1. User Info Section (Wrapped in Expanded) ---
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: Colors.purple,
                    size: 34.0,
                  ),
                  const SizedBox(width: 20),

                  // Wrap the Column in Expanded so text truncates properly
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userEmail,
                          maxLines: 1, // Ensures it stays on one line
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis, // Adds "..."
                        ),
                        CustomText("Caregiver", fromLeft: 0, fontSize: 11),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. Dynamic Action Section (StreamBuilder) ---
            // This stays outside the Expanded widget so it always has space
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('PendingRequests')
                  .where('Sender', isEqualTo: patientEmail)
                  .where('Receiver', isEqualTo: userEmail)
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
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () async {
                    try {
                      await addPendingRequest(
                        senderEmail: patientEmail,
                        receiverEmail: userEmail,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Request sent to $userEmail'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      onSuccess();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              e.toString().replaceAll("Exception: ", "")),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Icon(
                    Icons.add,
                    color: Colors.pink,
                    size: 30.0,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Future<void> addPendingRequest({
    required String senderEmail,
    required String receiverEmail,
  }) async {
    // 1. Check if a request already exists
    final QuerySnapshot existingRequests = await FirebaseFirestore.instance
        .collection('PendingRequests')
        .where('Sender', isEqualTo: senderEmail)
        .where('Receiver', isEqualTo: receiverEmail)
        .limit(1) // Optimization: Stop searching after finding one
        .get();

    // 2. If we found a document, stop and throw an error
    if (existingRequests.docs.isNotEmpty) {
      throw 'Request already pending with this user.';
    }

    // 3. If no duplicate found, proceed to add
    try {
      await FirebaseFirestore.instance.collection('PendingRequests').add({
        'Date': Timestamp.now(),
        'Sender': senderEmail,
        'Receiver': receiverEmail,
        'Type': 'From Patient To Caregiver',
        'isSenderPatient': true,
      });
    } catch (e) {
      throw Exception('Failed to add pending request: $e');
    }
  }

  Future<void> _removeCaregiver(BuildContext context, String careGiverEmail, String patientEmail) async {
    try {
      // A. Remove from Friendship Collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Friendship')
          .where('Patient', isEqualTo: patientEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;
        await docRef.update({
          'Caregivers': FieldValue.arrayRemove([careGiverEmail])
        });

        // --- THE FIX: ALSO DELETE THE PENDING REQUEST ---
        // We search for the request that caused this "Pending" status and delete it.
        final pendingQuery = await FirebaseFirestore.instance
            .collection('PendingRequests')
            .where('Sender', isEqualTo: patientEmail)
            .where('Receiver', isEqualTo: careGiverEmail)
            .get();

        for (var doc in pendingQuery.docs) {
          await doc.reference.delete();
        }
        // ------------------------------------------------

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Caregiver removed successfully'),
            backgroundColor: Colors.purple,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }


  Future<List<String>> _getListOfMembers(String patientEmail) async {
    try {
      // 1. Query for the document
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Friendship')
          .where('Patient', isEqualTo: patientEmail)
          .limit(1)
          .get();

      // 2. Check if document exists
      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();

        // 3. Extract and cast the 'Caregivers' array
        // Using List.from ensures we safely convert the dynamic Firestore list to List<String>
        if (data.containsKey('Caregivers') && data['Caregivers'] != null) {
          return List<String>.from(data['Caregivers']);
        }
      }

      // Return an empty list if no document found or array is empty
      return [];
    } catch (e) {
      if (kDebugMode) {
        print("Error getting members: $e");
      }
      return []; // Return empty list on error to handle gracefully
    }
  }
}