// lib/screens/provider_all_orders_screen.dart
import "package:flutter/material.dart";
import "../services/demo_data.dart";

class ProviderAllOrdersScreen extends StatelessWidget {
  const ProviderAllOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final list = DemoOrders.providerOrders;
    return Scaffold(
      appBar: AppBar(title: const Text("Munkáim")),
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
