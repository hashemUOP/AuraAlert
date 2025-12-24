import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


//this code asks patient permission to read his location in background and sending it to caregiver
//shareLocation function is called in main.dart on app launch if userType == patient
class LocationService {
  final Location _location = Location();

  Future<void> shareLocation(String userId) async {
    // 1. Permission checks
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // ✅ ADD THIS SECTION: Enable Background Mode
    // This creates the notification "App is running in background"
    try {
      await _location.enableBackgroundMode(enable: true);

      // Optional: Customize the Android notification
      await _location.changeNotificationOptions(
        title: 'Sharing Location',
        subtitle: 'Your caregiver can see your location.',
        iconName: 'ic_launcher', // Ensure this icon exists in android/app/src/main/res/mipmap
      );
    } catch (e) {
      print("Error enabling background mode: $e");
    }

    // 2. Listen to stream
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude == null || currentLocation.longitude == null) return;

      if (kDebugMode) {
        print("📍 NEW LOCATION: ${currentLocation.latitude}, ${currentLocation.longitude}");
        print("im in location");
      }

      GeoPoint geoPoint = GeoPoint(currentLocation.latitude!, currentLocation.longitude!);

      FirebaseFirestore.instance.collection('locations').doc(userId).set({
        'Lat&Long': geoPoint,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}