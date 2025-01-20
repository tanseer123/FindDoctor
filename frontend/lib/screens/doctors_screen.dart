// frontend/lib/screens/doctors_screen.dart

import 'package:flutter/material.dart';

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve doctors data passed as arguments
    final List<dynamic> doctors = ModalRoute.of(context)!.settings.arguments as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Doctors')),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return ListTile(
            title: Text(doctor['name']),
            subtitle: Text('${doctor['specialization']} - \$${doctor['fee']}'),
            onTap: () {
              // Optionally, navigate to a detailed profile or appointment scheduling
            },
          );
        },
      ),
    );
  }
}
