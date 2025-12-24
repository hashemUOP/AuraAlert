import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveTrackingPage extends StatefulWidget {
  final String targetUserId;

  const LiveTrackingPage({Key? key, required this.targetUserId}) : super(key: key);

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('locations')
            .doc(widget.targetUserId)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>?;

          // 2. Data Validation
          // Check if data exists AND if your specific field 'Lat&Long' exists
          if (data == null || !data.containsKey('Lat&Long')) {
            return const Center(child: Text("User location not found"));
          }

          // 3. Extract GeoPoint
          // Your field is named "Lat&Long" and is of type GeoPoint
          GeoPoint geoPoint = data['Lat&Long'] as GeoPoint;

          // Convert to Google Maps LatLng
          LatLng userPosition = LatLng(geoPoint.latitude, geoPoint.longitude);

          // 4. Move Camera
          _controller?.animateCamera(CameraUpdate.newLatLng(userPosition));

          return GoogleMap(
            initialCameraPosition: CameraPosition(target: userPosition, zoom: 15),
            onMapCreated: (controller) => _controller = controller,
            markers: {
              Marker(
                markerId: const MarkerId('targetUser'),
                position: userPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                // We can even show the patient name if needed
                infoWindow: InfoWindow(
                  title: "Patient Location",
                  snippet: data['patient'] ?? "",
                ),
              ),
            },
          );
        },
      ),
    );
  }
}