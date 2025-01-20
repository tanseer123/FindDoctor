// frontend/lib/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/emergency_service.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final EmergencyService _emergencyService = EmergencyService();
  final Set<Marker> _markers = {};
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _loadDoctors();
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Permissions are denied, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  Future<void> _loadDoctors() async {
    if (_currentPosition == null) {
      // Wait until the current position is fetched
      await Future.delayed(const Duration(seconds: 2));
      if (_currentPosition == null) {
        // Still no position, abort loading doctors
        return;
      }
    }

    try {
      List<dynamic> doctors = await _emergencyService.fetchNearbyDoctors(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      setState(() {
        for (var doctor in doctors) {
          _markers.add(
            Marker(
              markerId: MarkerId(doctor['id']),
              position: LatLng(
                doctor['location']['coordinates'][1],
                doctor['location']['coordinates'][0],
              ),
              infoWindow: InfoWindow(
                title: doctor['name'],
                snippet: '${doctor['specialization']} - \$${doctor['fee']}',
              ),
            ),
          );
        }
      });
    } catch (e) {
      print('Error loading doctors on map: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load doctors on map')),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          12,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emergencyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialPosition = const LatLng(37.7749, -122.4194); // Default to San Francisco

    if (_currentPosition != null) {
      initialPosition =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Doctors Map')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition:
            CameraPosition(target: initialPosition, zoom: 12),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
