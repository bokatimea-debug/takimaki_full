// lib/screens/customer_messages_screen.dart
import 'package:flutter/material.dart';

class CustomerMessagesScreen extends StatelessWidget {
  const CustomerMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üzenetek')),
      body: const Center(child: Text('Megrendelő üzenetek (helyőrző)')),
    );
  }
}
