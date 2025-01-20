// frontend/lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../widgets/emergency_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar with title
      appBar: AppBar(
        title: const Text('FindDoctor App'),
      ),
      // Body with Emergency Button and Navigation to Map
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmergencyButton(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/map');
              },
              child: const Text('View Doctors on Map'),
            ),
          ],
        ),
      ),
    );
  }
}
