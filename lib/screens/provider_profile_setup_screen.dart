import 'package:flutter/material.dart';

class ProviderProfileSetupScreen extends StatelessWidget {
  const ProviderProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltató profil')),
      body: const Center(child: Text('Szolgáltatói profil beállítás (helyőrző)')),
    );
  }
}
