import 'package:aura_alert/navbar_pages/home/HomeCareGiver.dart';
import 'package:aura_alert/navbar_pages/home/HomePatient.dart';
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
    // 1. try to reading from Local Storage first for faster results
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
      // 2. if local storage is empty, fetch from Firebase
      // getIsPatient is defined in main
      bool? firebaseStatus = await getIsPatient();

      if (mounted) {
        setState(() {
          // if firebase returns null (error), default to false or handle error
          isPatient = firebaseStatus ?? false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // show loading while until user state is figured out
    if (isPatient == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return isPatient! ? const HomePagePatient() : const HomePageCaregiver();
  }
}