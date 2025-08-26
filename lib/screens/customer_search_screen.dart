import 'package:flutter/material.dart';

class CustomerSearchScreen extends StatelessWidget {
  const CustomerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keresés')),
      body: const Center(child: Text('Megrendelő keresés kezdőképernyő (helyőrző)')),
    );
  }
}
