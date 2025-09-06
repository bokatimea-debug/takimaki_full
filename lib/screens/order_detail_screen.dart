import "package:flutter/material.dart";

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final rating = (order["rating"] as Map<String, dynamic>?) ?? {};
    final txt = (rating["text"] as String?) ?? "Nincs értékelés";
    final stars = (rating["stars"] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Rendelés részletei")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Szolgáltatás: ${order["serviceName"] ?? "-"}", style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Időpont: ${order["whenStr"] ?? "-"}"),
          const SizedBox(height: 16),
          const Text("Értékelés:"),
          const SizedBox(height: 8),
          Text("Csillagok: $stars / 5"),
          const SizedBox(height: 4),
          Text(txt),
        ],
      ),
    );
  }
}
