import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmergencyService {
  final String _baseUrl;
  IO.Socket? _socket;

  EmergencyService() : _baseUrl = dotenv.env['BACKEND_URL'] ?? 'https://cuddly-yodel-gr9r5rvw7p4h6v-3000.app.github.dev/api' {
    print('Initializing EmergencyService with base URL: $_baseUrl');
    _initializeSocket();
  }

  void _initializeSocket() {
    try {
      final socketUrl = dotenv.env['BACKEND_URL']?.replaceAll('/api', '') ?? 'https://cuddly-yodel-gr9r5rvw7p4h6v-3000.app.github.dev/api';
      print('Connecting to socket at: $socketUrl');

      _socket = IO.io(socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
      });

      _socket!.onConnect((_) {
        print('✅ Socket connected successfully');
      });

      _socket!.onConnectError((error) {
        print('❌ Socket connection error: $error');
      });

      _socket!.onError((error) {
        print('❌ Socket error: $error');
      });

      _socket!.onDisconnect((_) {
        print('❌ Socket disconnected');
      });
    } catch (e) {
      print('❌ Error initializing socket: $e');
    }
  }

  Future<List<dynamic>> fetchNearbyDoctors(double lat, double lng) async {
    try {
      print('Fetching doctors at lat: $lat, lng: $lng');
      print('Request URL: $_baseUrl/doctors/nearby?lat=$lat&lng=$lng');

      final response = await http.get(
        Uri.parse('$_baseUrl/doctors/nearby?lat=$lat&lng=$lng'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final doctors = json.decode(response.body);
        print('Successfully fetched ${doctors.length} doctors');
        return doctors;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching doctors: $e');
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  void sendEmergencyRequest(Map<String, dynamic> data) {
    try {
      print('Sending emergency request with data: $data');
      _socket?.emit('emergency_request', data);
    } catch (e) {
      print('❌ Error sending emergency request: $e');
    }
  }

  void dispose() {
    try {
      _socket?.disconnect();
      _socket?.dispose();
      print('Socket disposed successfully');
    } catch (e) {
      print('❌ Error disposing socket: $e');
    }
  }
}