// lib/screens/provider_profile_screen.dart
import 'package:flutter/material.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltató profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profilkép + értékelés + sikeres munkák
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 12),
            const Text('⭐ 4.7 / 5.0', style: TextStyle(fontSize: 18)),
            const Text('24 sikeres munka', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Profil szerkesztése gomb
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/provider/edit_profile');
                },
                child: const Text('Profil szerkesztése'),
              ),
            ),
            const SizedBox(height: 24),

            // Szolgáltatások gomb
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/provider/services');
                },
                child: const Text('Szolgáltatások'),
              ),
            ),
            const SizedBox(height: 24),

            // Beérkezett ajánlatkérések
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/provider/requests');
                },
                child: const Text('Beérkezett ajánlatkérések'),
              ),
            ),
            const SizedBox(height: 12),

            // Üzenetek
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/provider/messages');
                },
                child: const Text('Üzenetek'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
