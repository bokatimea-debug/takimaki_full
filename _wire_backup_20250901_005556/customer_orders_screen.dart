// lib/screens/customer_orders_screen.dart
import "package:flutter/material.dart";
import "../services/demo_data.dart";

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final list = DemoOrders.customerOrders;
    return Scaffold(
      appBar: AppBar(title: const Text("Rendeléseim")),
      body: ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final it = list[i];
          return ListTile(
            title: Text(it["title"]!),
            subtitle: Text("${it["date"]} • ${it["status"]}"),
          );
        },
      ),
    );
  }
}
