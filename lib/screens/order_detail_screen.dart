import "package:flutter/material.dart";

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final title = (order["serviceName"] ?? "Rendelés").toString();
    final when  = (order["whenStr"] ?? "").toString();
    final note  = (order["note"] ?? "").toString();
    final rating = order["rating"] is Map ? order["rating"] as Map : null;

    return Scaffold(
      appBar: AppBar(title: const Text("Rendelés részletei")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (when.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.schedule), const SizedBox(width: 8), Text(when)]),
          ],
          if (note.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text("Megjegyzés:", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(note),
          ],
          const SizedBox(height: 16),
          if (rating != null) ...[
            const Divider(),
            const SizedBox(height: 8),
            const Text("Értékelés", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text("Csillag: ${rating["stars"] ?? "-"}"),
            if ((rating["text"] ?? "").toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text((rating["text"] ?? "").toString()),
            ],
          ],
        ],
      ),
    );
  }
}
