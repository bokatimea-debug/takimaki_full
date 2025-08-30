// lib/screens/registration_success_screen.dart
import 'package:flutter/material.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 72, color: Colors.green),
            const SizedBox(height: 16),
            const Text('Sikeres regisztráció!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Most már használhatod a Takimaki appot.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/role_select',
                    (route) => false,
                  );
                },
                child: const Text('Folytatás'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
