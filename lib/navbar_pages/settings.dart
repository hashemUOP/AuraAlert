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

/// 🔥 Fetch the signed-in user's full data from Firestore (UsersInfo collection)
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    IconData patientIcon = Icons.person;
    IconData caregiverIcon = Icons.health_and_safety;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: Colors.white, automaticallyImplyLeading: false),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Settings", style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 30),
              ColorChangingContainer(
                icon: const Icon(Icons.bug_report_outlined, color: Colors.black54),
                iconPost: const Icon(Iconsax.arrow_right_3, color: Colors.black54),
                iconPostPadding: screenWidth * 0.423,
                inWidget: const CustomText(
                  'Report bug',
                  fromLeft: 10,
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              isPatient  == null ?
                const SizedBox.shrink()       // show nothing if isPatient is null
              : isPatient == true?            //show  ColorChangingContainer
              ColorChangingContainer(
                icon: const Icon(Iconsax.star, color: Colors.black54),
                iconPost: const Icon(Iconsax.arrow_right_3, color: Colors.black54),
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
                iconPost: const Icon(Iconsax.arrow_right_3, color: Colors.black54),
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
                icon: const Icon(FontAwesomeIcons.solidCircleUser, color: Colors.black54),
                iconPost: const Icon(Iconsax.arrow_right_3, color: Colors.black54),
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
                      const SnackBar(content: Text('No user is currently signed in.')),
                    );
                    return;
                  }
                  if (userData == null) {
                    showDialog(
                      context: context,
                      builder: (context) => const Center(
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
                                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      user!.displayName ?? "Unknown User", // user name from fire auth
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
                                icon: userData!['isPatient']! ? patientIcon : caregiverIcon,
                                title: "Current State",
                                value: userData!['isPatient']! ? "Patient" : "Care Giver",
                              ),

                              _infoTile(
                                icon: Icons.calendar_month,
                                title: "Join Date",
                                value: userData!['createdAt'] != null
                                    ? DateFormat('dd/MM/yyyy').format(
                                  (userData!['createdAt'] as Timestamp).toDate(),
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
                iconPost: const Icon(Iconsax.arrow_right_3, color: Colors.black54),
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
                  try {
                    await _authService.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: $e')),
                    );
                  }
                  await _deleteSharedData();
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
                  await _authService.deleteUser(context);
                  await _deleteSharedData();
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

  Widget _userInfoRow(String title, String value) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _deleteSharedData()async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('user_name');
  await prefs.remove('isPatient');

  if (kDebugMode) {
    print("All shared pref data has been cleared.");
  }
}

