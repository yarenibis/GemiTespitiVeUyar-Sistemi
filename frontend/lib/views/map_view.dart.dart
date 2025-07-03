import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../viewmodels/upload_viewmodel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _userPosition;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) return;
    }

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _userPosition = LatLng(pos.latitude, pos.longitude);
    });

    // Konumu ViewModel'e aktar
    Provider.of<UploadViewModel>(context, listen: false).setLocation(_userPosition!);

    _mapController.animateCamera(CameraUpdate.newLatLngZoom(_userPosition!, 15));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Konumunuz")),
      body: _userPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(target: _userPosition!, zoom: 15),
              myLocationEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  position: _userPosition!,
                  infoWindow: const InfoWindow(title: "Konumunuz"),
                )
              },
            ),
    );
  }
}
