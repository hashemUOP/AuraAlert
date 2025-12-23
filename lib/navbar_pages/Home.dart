import 'package:aura_alert/navbar_pages/home/HomeCareGiver.dart';
import 'package:aura_alert/navbar_pages/home/HomePatient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // getIsPatient() is defined here

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = "User";
  bool? isPatient;

  @override
  void initState() {
    super.initState();
    // is user patient or caregiver
    loadUserType();

    // load locally saved name immediately (for speed)
    _loadUsersFirstName();

  }

  String getFirstWord(String input) {
    return input.trim().split(' ').first;
  }

  Future<void> _loadUsersFirstName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser != null){
      userName = getFirstWord(currentUser.displayName!);
    }
  }

  Future<void> loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    bool? localStatus = prefs.getBool('isPatient');

    if (localStatus != null) {
      if (mounted) {
        setState(() {
          isPatient = localStatus;
        });
      }
    } else {
      bool? firebaseStatus = await getIsPatient();
      if (mounted) {
        setState(() {
          isPatient = firebaseStatus ?? false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    // Show loading until user type is determined
    if (isPatient == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return isPatient!
        ? HomePagePatient(userName: userName)
        : HomePageCaregiver(userName: userName);
  }
}