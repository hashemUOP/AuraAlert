import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:aura_alert/global_widgets/custom_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PatientList extends StatefulWidget {
  const PatientList({super.key});

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ""; // Variable to keep track of what the user types

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView( // Changed to SingleChildScrollView for the whole page to avoid overflow
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

          // Your existing static list
          Column(children: [
            _caregiversRow("email@example.com", screenWidth),
            _caregiversRow("test@test.com", screenWidth),
          ]),

          SizedBox(height: 20),
          Align(
            alignment: AlignmentGeometry.topLeft,
            child: CustomText("Pending Requests:", fromLeft: 0, fontSize: 18),
          ),
          SizedBox(height: 20),
          _notAvailable(screenWidth, false),
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
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("No user found with that email."),
          );
        }

        // Render the list of found users
        return Container(
          // Optional: Add a subtle background color or border to distinguish results
          padding: EdgeInsets.symmetric(vertical: 10),
          color: Colors.grey.withOpacity(0.05),
          child: Column(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              String userEmail = data['email'] ?? 'No Email';

              // Using your existing _requestRow function to display the result
              return _searchRow(userEmail, screenWidth);
            }).toList(),
          ),
        );
      },
    );
  }
}

Widget _notAvailable(double screenWidth, bool isForRequest) {
  return Container(
    height: 60,
    width: screenWidth * 0.99,
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.grey.shade100,
    ),
    child: Align(
      alignment: AlignmentGeometry.center,
      child: CustomText(
        isForRequest
            ? "You don't have any caregivers yet. Try adding one!"
            : "You don't have any pending requests.",
        fromLeft: 0,
      ),
    ),
  );
}

Widget _requestRow(String email, screenWidth) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Container(
      height: 70,
      width: screenWidth * 0.99,
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.purple,
                size: 34.0,
              ),
              SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(email, fromLeft: 0, fontSize: 20),
                  CustomText("Caregiver", fromLeft: 0, fontSize: 11),
                ],
              ),
            ],
          ),
          Icon(
            Icons.close,
            color: Colors.pink,
            size: 30.0,
          ),
        ],
      ),
    ),
  );
}

Widget _caregiversRow(String email, screenWidth) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Container(
      height: 70,
      width: screenWidth * 0.99,
      padding: EdgeInsets.symmetric(horizontal: 15,),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.purple,
                size: 34.0,
              ),
              SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(email, fromLeft: 0, fontSize: 20),
                  CustomText("Caregiver", fromLeft: 0, fontSize: 11),
                ],
              ),
            ],
          ),
          Icon(
            Icons.favorite,
            color: Colors.pink,
            size: 30.0,
          ),
        ],
      ),
    ),
  );
}

Widget _searchRow(String email, screenWidth) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Container(
      height: 70,
      width: screenWidth * 0.99,
      padding: EdgeInsets.symmetric(horizontal: 15,),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.purple,
                size: 34.0,
              ),
              SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(email, fromLeft: 0, fontSize: 20),
                  CustomText("Caregiver", fromLeft: 0, fontSize: 11),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: ()=>print("hashem"),
            child: Icon(
              Icons.add,
              color: Colors.pink,
              size: 30.0,
            ),
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
  try {
    await FirebaseFirestore.instance
        .collection('PendingRequests')
        .add({
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