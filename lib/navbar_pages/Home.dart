import 'package:aura_alert/navbar_pages/home/HomeCareGiver.dart';
import 'package:aura_alert/navbar_pages/home/HomePatient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool? isPatient;

  @override
  void initState() {
    super.initState();
    loadUserType();
  }

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


  @override
  Widget build(BuildContext context) {
    // Show loading while we figure out who the user is
    if (isPatient == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Render the correct page
    return isPatient! ? const HomePagePatient() : const HomePageCaregiver();
  }
}