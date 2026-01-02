import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// This code asks patient permission to read location in background and send to caregiver
// shareLocation function is called in main.dart on app launch if userType == patient
class LocationService {
  final Location _location = Location();

  Future<void> shareLocation(String userId) async {
    // 1. Service & Permission checks
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

    // ✅ CRITICAL FIX: Force High Accuracy Settings
    // Without this, the OS throttles updates to save battery.
    // interval: 5000 = update every 5 seconds
    // distanceFilter: 0 = update even if movement is small
    try {
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 5000,
        distanceFilter: 0,
      );
    } catch (e) {
      print("Error changing location settings: $e");
    }

    // 2. Enable Background Mode
    try {
      await _location.enableBackgroundMode(enable: true);

      // Customize the Android notification so the user knows they are being tracked
      await _location.changeNotificationOptions(
        title: 'AuraAlert Active',
        subtitle: 'Sharing location with caregiver...',
        iconName: 'ic_launcher',
        onTapBringToFront: true,
      );
    } catch (e) {
      print("Error enabling background mode: $e");
    }

    // 3. Listen to stream and update Firestore
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude == null || currentLocation.longitude == null) return;

      if (kDebugMode) {
        print("📍 NEW LOCATION: ${currentLocation.latitude}, ${currentLocation.longitude} | Speed: ${currentLocation.speed}");
      }

      GeoPoint geoPoint = GeoPoint(currentLocation.latitude!, currentLocation.longitude!);

      FirebaseFirestore.instance.collection('locations').doc(userId).set({
        'Lat&Long': geoPoint,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}