// frontend/lib/widgets/emergency_button.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/emergency_service.dart';

class EmergencyButton extends StatelessWidget {
  final EmergencyService _emergencyService = EmergencyService();

  EmergencyButton({super.key});

  Future<void> _handleEmergency(BuildContext context) async {
    // Request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Permissions are denied, show a message and return
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),          
        );
        return;
      }
    }

    // Get user's current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Prepare emergency request data
    Map<String, dynamic> emergencyData = {
      'userId': 'user123', // Replace with actual user ID if applicable
      'location': {'lat': position.latitude, 'lng': position.longitude},
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Send emergency request via Socket.io
    _emergencyService.sendEmergencyRequest(emergencyData);

    // Optionally, fetch nearby doctors
    try {
      List<dynamic> doctors = await _emergencyService.fetchNearbyDoctors(
        position.latitude,
        position.longitude,
      );
      // Navigate to doctors screen with fetched data
      Navigator.pushNamed(context, '/doctors', arguments: doctors);
    } catch (e) {
      print('Error fetching doctors: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch nearby doctors')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleEmergency(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Emergency',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}
