// lib/screens/customer_orders_screen.dart
import 'package:flutter/material.dart';

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rendeléseim')),
      body: const Center(child: Text('Itt lesz az összes rendelés listája')),
    );
  }
}
