import 'package:aura_alert/navbar_pages/home/HomeCareGiver.dart';
import 'package:aura_alert/navbar_pages/home/HomePatient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

Future<bool?> getIsPatient() async {
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
    return data['isPatient'] as bool?;
  } catch (e) {
    if (kDebugMode) {
      print('Error getting isPatient: $e');
    }
    return null;
  }
}

class _HomeState extends State<Home> {
  bool? isPatient;

  @override
  void initState() {
    super.initState();
    loadUserType();
  }

  Future<void> loadUserType() async {
    final value = await getIsPatient();
    setState(() {
      isPatient = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isPatient == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return isPatient! ? HomePagePatient() : HomePageCaregiver();
  }
}
