// lib/screens/provider_messages_screen.dart
import 'package:flutter/material.dart';

class ProviderMessagesScreen extends StatelessWidget {
  const ProviderMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üzenetek')),
      body: const Center(child: Text('Szolgáltatói üzenetek (helyőrző)')),
    );
  }
}
