// lib/screens/provider_requests_screen.dart
import 'package:flutter/material.dart';

class ProviderRequestsScreen extends StatelessWidget {
  const ProviderRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beérkezett ajánlatkérések')),
      body: const Center(child: Text('Itt lesznek a beérkezett ajánlatkérések')),
    );
  }
}
