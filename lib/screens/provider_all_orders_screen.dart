// lib/screens/provider_all_orders_screen.dart
import 'package:flutter/material.dart';

class ProviderAllOrdersScreen extends StatelessWidget {
  const ProviderAllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Munkáim')),
      body: const Center(child: Text('Itt lesz az összes teljesített munka')),
    );
  }
}
