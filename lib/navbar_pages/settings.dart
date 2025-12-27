import 'package:aura_alert/login_signup_welcome/screens/welcome_screen.dart';
import 'package:aura_alert/navbar_pages/settings/caregiver_list.dart';
import 'package:aura_alert/navbar_pages/settings/patient_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:aura_alert/global_widgets/animated_button.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';
import 'package:aura_alert/login_signup_welcome/auth_services.dart';
import 'package:aura_alert/global_widgets/color_changing_container.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

/// fetch the signed-in user's full data from Firestore (UsersInfo collection)
Future<Map<String, dynamic>?> getUserData() async {
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

    return {
      'name': data['name'],
      'email': data['email'],
      'createdAt': data['createdAt'],
      'isPatient': data['isPatient'],
      'phone': data['phone'],
    };
  } catch (e) {
    if (kDebugMode) {
      print("Error fetching user data: $e");
    }
    return null;
  }
}



Widget _infoTile({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F2FB),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: const Color(0xFF8e44ad)),
        const SizedBox(width: 15),

        // TEXTS
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}


class _SettingsState extends State<Settings> {
  bool? isPatient;

  final AuthService _authService = AuthService();
  User? user = FirebaseAuth.instance.currentUser;


  Future<void> loadUserType() async {
    // 1. Try to read from Local Storage first (It's faster)
    final prefs = await SharedPreferences.getInstance();
    bool? localStatus = prefs.getBool('isPatient');

    if (localStatus != null) {
      // If we found it locally, use it immediately
      if (mounted) {
        setState(() {
          isPatient = localStatus;
        });
      }
    } else {
      // 2. If local storage is empty, fetch from Firebase
      // getIsPatient is defined in main
      bool? firebaseStatus = await getIsPatient();

      if (mounted) {
        setState(() {
          // If firebase returns null (error), default to false or handle error
          isPatient = firebaseStatus ?? false;
        });
      }
    }
  }

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    loadUserType();
  }


  Future<void> loadUserInfo() async {
    final data = await getUserData();
    if (mounted) {
      setState(() {
        userData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    IconData patientIcon = Icons.person;
    IconData caregiverIcon = Icons.health_and_safety;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
            backgroundColor: Colors.white, automaticallyImplyLeading: false),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    "Settings", style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 30),
              ColorChangingContainer(
                icon: const Icon(
                    Icons.bug_report_outlined, color: Colors.black54),
                iconPost: const Icon(
                    Iconsax.arrow_right_3, color: Colors.black54),
                iconPostPadding: screenWidth * 0.423,
                inWidget: const CustomText(
                  'Report bug',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              isPatient == null ?
              const SizedBox.shrink() // show nothing if isPatient is null
                  : isPatient == true ? //show  ColorChangingContainer
              ColorChangingContainer(
                icon: const Icon(Iconsax.star, color: Colors.black54),
                iconPost: const Icon(
                    Iconsax.arrow_right_3, color: Colors.black54),
                iconPostPadding: screenWidth * 0.423,
                inWidget: const CustomText(
                  'Caregiver List',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Container(
                          height: screenHeight * 0.75,
                          width: screenWidth,
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                              child: PatientList()
                          ),
                        ),
                      );
                    },
                  );
                },
              )
                  : // if isPatient == false show ColorChangingContainer Patient
              ColorChangingContainer(
                icon: const Icon(Iconsax.star, color: Colors.black54),
                iconPost: const Icon(
                    Iconsax.arrow_right_3, color: Colors.black54),
                iconPostPadding: screenWidth * 0.423,
                inWidget: const CustomText(
                  'Patient Management',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),

                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Container(
                          height: screenHeight * 0.75,
                          width: screenWidth,
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                              child: CaregiverList()
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              ColorChangingContainer(
                icon: const Icon(
                    FontAwesomeIcons.solidCircleUser, color: Colors.black54),
                iconPost: const Icon(
                    Iconsax.arrow_right_3, color: Colors.black54),
                iconPostPadding: screenWidth * 0.423,
                inWidget: const CustomText(
                  'User\'s Info',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                onTap: () {
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('No user is currently signed in.')),
                    );
                    return;
                  }
                  if (userData == null) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    return;
                  }

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 25),
                          height: screenHeight * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 20,
                                color: Colors.black.withOpacity(0.15),
                              )
                            ],
                          ),
                          child: Column(
                            children: [

                              // -------- GRADIENT HEADER WITH AVATAR --------
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8e44ad),
                                      Color(0xFF9b59b6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 45,
                                      backgroundColor: Colors.white,
                                      backgroundImage: user!.photoURL != null
                                          ? NetworkImage(user!.photoURL!)
                                          : null,
                                      child: user!.photoURL == null
                                          ? const Icon(Icons.person, size: 50,
                                          color: Colors.grey)
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      user!.displayName ?? "Unknown User",
                                      // user name from fire auth
                                      // userData!['name'] ?? "Unknown User", //user name from collection UsersInfo
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),

                              // -------- USER INFO SECTION --------
                              _infoTile(
                                icon: Icons.email_rounded,
                                title: "Email",
                                value: user!.email ?? "N/A",
                              ),

                              _infoTile(
                                  icon: Icons.phone_android_rounded,
                                  title: "Phone",
                                  value: userData!['phone'] ?? "Not Provided"
                              ),

                              _infoTile(
                                icon: userData!['isPatient']!
                                    ? patientIcon
                                    : caregiverIcon,
                                title: "Current State",
                                value: userData!['isPatient']!
                                    ? "Patient"
                                    : "Care Giver",
                              ),

                              _infoTile(
                                icon: Icons.calendar_month,
                                title: "Join Date",
                                value: userData!['createdAt'] != null
                                    ? DateFormat('dd/MM/yyyy').format(
                                  (userData!['createdAt'] as Timestamp)
                                      .toDate(),
                                )
                                    : "Not Provided",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              ColorChangingContainer(
                icon: const Icon(Iconsax.global, color: Colors.black54),
                iconPost: const Icon(
                    Iconsax.arrow_right_3, color: Colors.black54),
                iconPostPadding: screenWidth * 0.423,
                inWidget: const CustomText(
                  'Change language',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                onTap: () {},
              ),
              ColorChangingContainer(
                onTap: () async {
                  await _deleteSharedData();
                  try {
                    await _authService.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const WelcomeScreen()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: $e')),
                    );
                  }
                },
                icon: const Icon(Iconsax.logout, color: Colors.black54),
                inWidget: const CustomText(
                  'Log out',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedButton(
                onTap: () async {
                  // safety check: user and email must exist
                  if (user == null || user!.email == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error: No user logged in")),
                    );
                    return;
                  }

                  // if user is patient delete Firestore patient data
                  // else delete caregiver data.
                  if (isPatient == true) {
                    await _deleteAllPatientDataFromFirebase(
                        context, user!.email!);
                  } else {
                    await _deleteAllCaregiverDataFromFirebase(
                        context, user!.email!);
                  }
                  await _deleteSharedData();
                  await _authService.deleteUser(context);
                },
                buttonColor: Colors.white,
                text: 'Delete my account',
                textColor: Colors.purple,
                textSize: 15,
                containerBorderColor: Colors.purple,
                containerRadius: 10,
                containerHeight: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _deleteSharedData()async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('isPatient');

  if (kDebugMode) {
    print("All shared pref data has been cleared.");
  }
}


Future<void> _deleteAllPatientDataFromFirebase(BuildContext context,String patientEmail) async {
  final firestore = FirebaseFirestore.instance;

  // create ONE batch to ensure all deletions happen together which means all get deleted or none at all (batch is used for rollback logic)
  // If any part fails, nothing is deleted.
  final batch = firestore.batch();

  try {
    ///////////////////////////////////////////////////////////////////////
    // delete patient from collection Friendship
    // get the list of documents that match the query
    final friendshipSnapshot = await firestore
        .collection("Friendship")
        .where("Patient", isEqualTo: patientEmail)
        .get();

    // loop through results and add "delete" operations to the batch
    for (var doc in friendshipSnapshot.docs) {
      batch.delete(doc.reference);
    }

    ///////////////////////////////////////////////////////////////////////
    /// delete patient from LastAnalysis
    // get the list of documents that match the query
    final lastAnalysisSnapshot = await firestore
        .collection("LastAnalysis")
        .where("patient", isEqualTo: patientEmail)
        .get();

    // loop through results and add "delete" operations to the batch
    for (var doc in lastAnalysisSnapshot.docs) {
      batch.delete(doc.reference);
    }

    ///////////////////////////////////////////////////////////////////////
    /// delete patient from Notify
    // get the list of documents that match the query
    final notifySnapshot = await firestore
        .collection("Notify")
        .where("patient", isEqualTo: patientEmail)
        .get();

    // loop through results and add "delete" operations to the batch
    for (var doc in notifySnapshot.docs) {
      batch.delete(doc.reference);
    }

    ///////////////////////////////////////////////////////////////////////
    /// delete patient from Reminders
    // get the list of documents that match the query
    final remindersSnapshot = await firestore
        .collection("Reminders")
        .where("patient", isEqualTo: patientEmail)
        .get();

    // loop through results and add "delete" operations to the batch
    for (var doc in remindersSnapshot.docs) {
      batch.delete(doc.reference);
    }

    ///////////////////////////////////////////////////////////////////////
    /// delete patient from UsersInfo
    final userInfoRef = firestore
        .collection("UsersInfo")
        .doc(patientEmail); // delete document when document id = patient email

    batch.delete(userInfoRef);

    ///////////////////////////////////////////////////////////////////////
    /// delete patient from locations
    final locationRef = firestore
        .collection("locations")
        .doc(patientEmail); // delete document when document id = patient email

    batch.delete(locationRef);

    // commit all deletions at once
    // batch has a rollback either all gets deleted all none get deleted
    await batch.commit();

    if (kDebugMode) {
      print("Successfully deleted all data for $patientEmail");
    }

  } catch (e) {
    if (kDebugMode) {
      print("Error deleting patient data: $e");
      // check if the widget is still on screen before showing Snackbar
      if (!context.mounted) return;

      // Show Error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> _deleteAllCaregiverDataFromFirebase(BuildContext context, String caregiverEmail) async {
  final firestore = FirebaseFirestore.instance;

  // create ONE batch to ensure all deletions happen together which means all get deleted or none at all (batch is used for rollback logic)
  // if any part fails, nothing is deleted.
  final batch = firestore.batch();

  try {
    // ---------------------------------------------------------
    // 1. Remove ONLY the caregiver's email from the "Caregivers" array don't delete document or field
    // ---------------------------------------------------------
    final friendshipSnapshot = await firestore
        .collection("Friendship")
        .where("Caregivers", arrayContains: caregiverEmail)
        .get();

    for (var doc in friendshipSnapshot.docs) {
      // batch.update does NOT replace the document.
      // FieldValue.arrayRemove does NOT delete the array field.
      // It simply removes the item 'caregiverEmail' from the list.
      // ex: ["mom@test.com", "you@test.com"] -> becomes -> ["mom@test.com"]
      batch.update(doc.reference, {
        "Caregivers": FieldValue.arrayRemove([caregiverEmail])
      });
    }

    // ---------------------------------------------------------
    // 2. Remove Caregiver from "Notify" Collection, delete caregiver email from array don't delete document or field
    // ---------------------------------------------------------
    final notifySnapshot = await firestore
        .collection("Notify")
        .where("caregivers", arrayContains: caregiverEmail)
        .get();

    for (var doc in notifySnapshot.docs) {
      // remove ONLY this email from the array
      batch.update(doc.reference, {
        "caregivers": FieldValue.arrayRemove([caregiverEmail])
      });
    }

    ///////////////////////////////////////////////////////////////////////
    /// delete caregiver document from UsersInfo
    final userInfoRef = firestore
        .collection("UsersInfo")
        .doc(caregiverEmail); // delete document when document id = patient email

    batch.delete(userInfoRef);

    // commit all deletions at once
    // batch has a rollback either all gets deleted all none get deleted
    await batch.commit();

    if (kDebugMode) {
      print("Successfully deleted all data for $caregiverEmail");
    }

  } catch (e) {
    if (kDebugMode) {
      print("Error deleting patient data: $e");
      // check if the widget is still on screen before showing Snackbar
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}