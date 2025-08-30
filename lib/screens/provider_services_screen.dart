// lib/screens/provider_services_screen.dart
import 'package:flutter/material.dart';

class ProviderServicesScreen extends StatelessWidget {
  const ProviderServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltatásaim')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pushNamed(context, '/provider/add_service');
              },
              child: const Text('Új szolgáltatás hozzáadása'),
            ),
          ),
          const Divider(),
          const Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Takarítás • H–P 9–18 • 8000 Ft/alkalom'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 12),
                      Icon(Icons.close, color: Colors.red),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('Villanyszerelés • Szo–V 10–16 • 12000 Ft/óra'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 12),
                      Icon(Icons.close, color: Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
