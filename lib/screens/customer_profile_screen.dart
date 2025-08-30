// lib/screens/customer_profile_screen.dart
import 'package:flutter/material.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Megrendelő profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profilkép + értékelés + rendelések száma
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 12),
            const Text('⭐ 4.8 / 5.0', style: TextStyle(fontSize: 18)),
            const Text('12 sikeres rendelés', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Akciógombok
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/customer/new_order');
                },
                child: const Text('Új rendelés leadása'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/customer/messages');
                },
                child: const Text('Üzenetek'),
              ),
            ),
            const Divider(height: 32),

            // Legutóbbi rendelések
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Legutóbbi rendeléseim',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            const ListTile(
              title: Text('Takarítás'),
              subtitle: Text('2025-08-29 • Teljesítve'),
            ),
            const ListTile(
              title: Text('Villanyszerelés'),
              subtitle: Text('2025-08-20 • Lemondva'),
            ),
            const ListTile(
              title: Text('Nagytakarítás'),
              subtitle: Text('2025-08-05 • Teljesítve'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/customer/orders');
              },
              child: const Text('Összes rendelés megtekintése'),
            ),
          ],
        ),
      ),
    );
  }
}
