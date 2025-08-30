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

            // Elérhetőség
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Elérhetőség: H–P 9–18, Szo 10–16',
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/provider/edit_availability');
                  },
                  child: const Text('Szerkesztés'),
                ),
              ],
            ),
            const Divider(height: 32),

            // Szolgáltatások
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Szolgáltatások:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/provider/edit_services');
                  },
                  child: const Text('Szerkesztés'),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Takarítás'),
                  Text('• Villanyszerelés'),
                  Text('• Bútorösszeszerelés'),
                ],
              ),
            ),
            const Divider(height: 32),

            // Akciógombok
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
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/provider/messages');
                },
                child: const Text('Üzenetek'),
              ),
            ),
            const Divider(height: 32),

            // Legutóbbi munkák
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Legutóbbi munkáim',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            const ListTile(
              title: Text('Nagytakarítás'),
              subtitle: Text('2025-08-28 • Teljesítve'),
            ),
            const ListTile(
              title: Text('Vízszerelés'),
              subtitle: Text('2025-08-20 • Teljesítve'),
            ),
            const ListTile(
              title: Text('Festés'),
              subtitle: Text('2025-08-15 • Lemondva'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/provider/all_orders');
              },
              child: const Text('Összes megtekintése'),
            ),
          ],
        ),
      ),
    );
  }
}
