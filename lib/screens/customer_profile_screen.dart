import 'package:flutter/material.dart';
import '../session.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UserSession.instance;
    final first = (s.firstName ?? 'Felhasználó').trim();
    final labelStyle = TextStyle(color: Colors.grey.shade700);

    return Scaffold(
      appBar: AppBar(title: const Text('Profilom')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: s.hasPhoto ? const Icon(Icons.check) : const Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Text(first, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),

            Text('Értékelés és statisztika', style: labelStyle),
            const SizedBox(height: 6),
            const Text('⭐ 4.7 • 7 db sikeres rendelés'),
            const SizedBox(height: 16),

            Text('Legutóbbi 3 rendelés', style: labelStyle),
            const SizedBox(height: 6),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Általános takarítás – 2025-08-18 10:00'),
              subtitle: Text('XIII. kerület, Demó utca 1. • Teljesítve'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Vízszerelés – 2025-08-12 14:00'),
              subtitle: Text('II. kerület, Minta u. 2. • Teljesítve'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Villanyszerelés – 2025-07-30 09:00'),
              subtitle: Text('XI. kerület, Próba tér 3. • Teljesítve'),
            ),
          ],
        ),
      ),
    );
  }
}
