import 'package:flutter/material.dart';
import '../widgets/rating_stars.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DEMÓ adatok
    const name = 'Kiss Júlia';
    const rating = 4.6;
    const success = 12;

    return Scaffold(
      appBar: AppBar(title: const Text('Megrendelői profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text(name),
              subtitle: RatingStars(rating: rating, successCount: success, isProvider: false),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Utolsó 3 megrendelés', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            for (final it in const ['Apartman takarítás – 17 000 Ft', 'Nagytakarítás – 30 000 Ft', 'Irodatisztítás – 12 000 Ft'])
              Card(child: ListTile(title: Text(it))),
          ],
        ),
      ),
    );
  }
}
