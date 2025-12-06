import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_screen.dart';
import 'package:aura_alert/navbar_pages/navbar.dart';
import 'package:aura_alert/global_widgets/custom_text.dart';

class Question3Screen extends StatefulWidget {
  const Question3Screen({super.key});

  @override
  State<Question3Screen> createState() => _Question3ScreenState();
}

class _Question3ScreenState extends State<Question3Screen> {
  String? _email;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState(){
    //get the email that the user logged in using google on page initial
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _email = FirebaseAuth.instance.currentUser?.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> createUserInfo({
    required String name,
    required String phone,
    required String email,
    required bool isPatient,
  }) async {
    try {
      // Get reference to 'User's Info' collection
      CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("UsersInfo");

      // Create a new document with auto-generated ID
      await usersCollection.add({
        'name': name,
        'phone': phone,
        'email': email,
        'isPatient': isPatient,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print("User document created successfully!");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error creating user document: $e");
      }
    }
  }

  bool intToBool(int value) {
    return value != 0;
  }

  Future<void> _saveNameInSharedRef() async {
    String name = _nameController.text.trim();

    //save the entered phone number to the shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    String? name_shared = prefs.getString('user_name');
    print('User name in shared ref : $name_shared');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const CustomText(
                    'Sign Up',
                    fontSize: 16,
                    color: Colors.black54,
                    fromLeft: 0.0,
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  'Enter your Name',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fromLeft: 0.0,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController, // <-- Add controller
                        keyboardType: TextInputType.text,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Name (Optional)',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await _saveNameInSharedRef(); // <-- Save name if entered

                  //email safety check
                  if (_email == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error: Missing user email")),
                    );
                    return;
                  }

                  /////////////////// create User's Info Document ////////////////////////////
                  //load shared ref data
                  final prefs = await SharedPreferences.getInstance();
                  //get all data stored in shared ref
                  int? choice = prefs.getInt('selectedOption');
                  String? phoneShared = prefs.getString('user_phone');
                  String? nameShared = prefs.getString('user_name');

                  try {
                    await createUserInfo(
                      name: nameShared ?? "",
                      phone: phoneShared ?? "",
                      isPatient: intToBool(choice ?? 0),
                      email: _email!,
                    );
                    if (kDebugMode) print("User document created successfully!");

                    //////////////////clear shared preferences///////////////////////
                    //after User's Info successfully created we will delete all shared ref data
                    await prefs.clear();
                    /////////////////////////////////////////////////////////////////

                    // Navigate to login screen
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MyNavBar()),
                    );
                  } catch (e) {
                    if (kDebugMode) print("Error creating user document: $e");
                  }
                  /////////////////////////////////////////////////////////////////////
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8e44ad),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const CustomText(
                  "Continue",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fromLeft: 0.0,
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    "Already have an account? ",
                    fontSize: 16,
                    color: Colors.grey[600],
                    fromLeft: 0.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (Route<dynamic> route) => route.isFirst,
                      );
                    },
                    child: const CustomText(
                      'Log In',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8e44ad),
                      fromLeft: 0.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

