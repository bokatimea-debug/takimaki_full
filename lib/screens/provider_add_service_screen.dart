// lib/screens/provider_add_service_screen.dart
import 'package:flutter/material.dart';

class ProviderAddServiceScreen extends StatelessWidget {
  const ProviderAddServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Új szolgáltatás hozzáadása')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Szolgáltatás neve'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Ár (Ft/óra vagy Ft/alkalom)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(labelText: 'Időszak (pl. H–P 9–18)'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Mentés'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
