import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aura_alert/navbar_pages/location/SenderLocation.dart';

class LocationManager extends StatefulWidget {
  final Widget child;

  const LocationManager({super.key, required this.child});

  @override
  State<LocationManager> createState() => _LocationManagerState();
}

class _LocationManagerState extends State<LocationManager> {
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    // ✅ Call one master function that handles the sequence
    _initializeLogic();
  }

  /// Master function to control the flow
  Future<void> _initializeLogic() async {
    // 1. Determine if user is a patient (Local -> then Firebase)
    bool isPatient = await _checkIfPatient();

    // 2. Only start location service if they ARE a patient
    if (isPatient) {
      await _startLocationService();
    }
  }

  /// Checks SharedPreferences first, then falls back to Firestore
  Future<bool> _checkIfPatient() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final prefs = await SharedPreferences.getInstance();

      // A. Check Local Storage
      if (prefs.containsKey('isPatient')) {
        return prefs.getBool('isPatient') ?? false;
      }

      // B. Check Firebase (Firestore) if local is empty
      if (kDebugMode) print("Local storage empty, checking Firestore for 'isPatient'...");

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('UsersInfo')
          .doc(user.email)
          .get();

      if (userDoc.exists) {
        // Assuming your field in Firestore is named 'isPatient' or 'role'
        // Adjust 'role' == 'patient' logic to match your database structure
        bool status = false;

        // Example 1: If you store it as a boolean field 'isPatient'
        if (userDoc.data().toString().contains('isPatient')) {
          status = userDoc.get('isPatient') == true;
        }
        // Example 2: If you store it as role string
        // else if (userDoc.get('role') == 'patient') { status = true; }

        // Save to local storage for next time
        await prefs.setBool('isPatient', status);
        return status;
      }

      return false;
    } catch (e) {
      if (kDebugMode) print("Error checking user type: $e");
      return false; // Fail safe
    }
  }

  Future<void> _startLocationService() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      Location location = Location();

      // 1. Ask to turn on GPS
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          if (kDebugMode) print("User denied GPS service.");
          return;
        }
      }

      // 2. Ask for Permission
      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          if (kDebugMode) print("User denied location permission.");
          return;
        }
      }

      // 3. Start Service
      if (kDebugMode) {
        print("🚀 PERMISSIONS GRANTED. STARTING LOCATION SHARING.");
      }
      _locationService.shareLocation(user.email!);

    } catch (e) {
      if (kDebugMode) print("Error starting location service: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}