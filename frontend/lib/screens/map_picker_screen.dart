import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  final Set<Marker> markers = {};

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(1.2966, 103.7764),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a location'),
        actions: [
          TextButton(
            onPressed: selectedLocation == null
                ? null
                : () => Navigator.pop(context, selectedLocation),
            child: const Text('Confirm'),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: initialPosition,
        onMapCreated: (controller) => mapController = controller,
        onTap: (latLng) {
          setState(() {
            selectedLocation = latLng;
            markers.clear();
            markers.add(
              Marker(
                markerId: const MarkerId('selected'),
                position: latLng,
              ),
            );
          });
        },
        markers: markers,
        myLocationEnabled: true, // shows blue dot if permission is granted
        myLocationButtonEnabled: true,
      ),
    );
  }
}