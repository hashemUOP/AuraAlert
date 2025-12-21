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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('UsersInfo')
          .where('isPatient', isEqualTo: false)
      // This creates a "starts with" query for the email field
          .where('email', isGreaterThanOrEqualTo: _searchQuery)
          .where('email', isLessThan: _searchQuery + 'z')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (kDebugMode) {
            print("Error: ${snapshot.error}");
          }
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("No user found with that email."),
          );
        }

        // Render the list of found users
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.grey.withOpacity(0.05),
          child: Column(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<
                  String,
                  dynamic>;
              String userEmail = data['email'] ?? 'No Email';

              return _searchRow(
                userEmail: userEmail,
                patientEmail: patientEmail!,
                screenWidth: screenWidth,
                context: context,
                // --- CLEANUP LOGIC ---
                onSuccess: () {
                  // 1. Clear the text controller
                  _searchController.clear();

                  // 2. Update state to hide results
                  setState(() {
                    _searchQuery = "";
                  });

                  // 3. Close the keyboard
                  FocusScope.of(context).unfocus();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

// Widget _requestRow(String email, screenWidth) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 5),
//     child: Container(
//       height: 70,
//       width: screenWidth * 0.99,
//       padding: EdgeInsets.symmetric(horizontal: 15),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         color: Colors.grey.shade100,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.person,
//                 color: Colors.purple,
//                 size: 34.0,
//               ),
//               SizedBox(width: 20),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CustomText(email, fromLeft: 0, fontSize: 20),
//                   CustomText("Caregiver", fromLeft: 0, fontSize: 11),
//                 ],
//               ),
//             ],
//           ),
//           Icon(
//             Icons.close,
//             color: Colors.pink,
//             size: 30.0,
//           ),
//         ],
//       ),
//     ),
//   );
// }

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
            // --- 1. User Info Section ---
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.purple,
                  size: 34.0,
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(userEmail, fromLeft: 0, fontSize: 16),
                    CustomText("Caregiver", fromLeft: 0, fontSize: 11),
                  ],
                ),
              ],
            ),

            // --- 2. Dynamic Action Section (StreamBuilder) ---
            StreamBuilder<QuerySnapshot>(
              // Listen for any pending request between these specific users
              stream: FirebaseFirestore.instance
                  .collection('PendingRequests')
                  .where('Sender', isEqualTo: patientEmail)
                  .where('Receiver', isEqualTo: userEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                // A. Check if data is loading (optional, keeps UI jump-free)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(width: 30, height: 30);
                }

                // B. Check if a request ALREADY exists
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

                // C. If NO request exists, show the Add button
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
                          content: Text(e.toString().replaceAll("Exception: ", "")),
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

  Future<void> _removeCaregiver(BuildContext context, String careGiverEmail,
      String patientEmail) async {
    try {
      // 1. Query the collection to find the document where 'Patient' matches patientEmail
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Friendship')
          .where('Patient', isEqualTo: patientEmail)
          .limit(1) // Limit to 1 since we expect a unique relationship doc
          .get();

      // 2. Check if the document exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get the reference of the found document
        final docRef = querySnapshot.docs.first.reference;

        // 3. Atomically remove the specific email from the 'Caregivers' array
        await docRef.update({
          'Caregivers': FieldValue.arrayRemove([careGiverEmail])
        });

        //Success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Caregiver removed successfully'),
            backgroundColor: Colors.purple,
          ),
        );
      } else {
        // no patient found snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No patient found')),
        );
      }
    } catch (e) {
      //error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing caregiver: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
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

// Future<List<String>> _getPendingRequests(String patientEmail) async {
//   try {
//     // 1. Query 'PendingRequests' where the SENDER is the current user
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('PendingRequests')
//         .where('Sender', isEqualTo: patientEmail)
//         .get();
//
//     // 2. Extract the 'Receiver' emails from the found documents
//     final receiverEmails = querySnapshot.docs.map((doc) {
//       final data = doc.data();
//       return data['Receiver'] as String? ?? '';
//     }).where((email) => email.isNotEmpty).toList();
//
//     return receiverEmails;
//
//   } catch (e) {
//     print("Error getting sent requests: $e");
//     return [];
//   }
// }
}
