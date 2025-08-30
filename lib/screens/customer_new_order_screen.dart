// lib/screens/customer_new_order_screen.dart
import 'package:flutter/material.dart';

class CustomerNewOrderScreen extends StatelessWidget {
  const CustomerNewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Új rendelés leadása')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            Navigator.pushNamed(context, '/customer/search');
          },
          child: const Text('Keresés indítása'),
        ),
      ),
    );
  }
}
