import "package:flutter/material.dart";

class CustomerOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const CustomerOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final title = order["title"] ?? "Rendelés";
    final dateStr = order["dateStr"] ?? "";
    final address = order["address"] ?? "";
    final serviceName = order["serviceName"] ?? "";
    final rating = (order["rating"] as num?)?.toDouble();
    final review = (order["review"] ?? "").toString();

    return Scaffold(
      appBar: AppBar(title: const Text("Rendelés részletei")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(dateStr),
          const SizedBox(height: 8),
          Text("Szolgáltatás: $serviceName"),
          const SizedBox(height: 8),
          Text("Cím: $address"),
          const Divider(height: 24),
          if (rating != null) ...[
            Row(
              children: List.generate(5, (i) {
                final full = rating >= (i + 1);
                final half = !full && rating > i;
                return Icon(full ? Icons.star : (half ? Icons.star_half : Icons.star_border), color: Colors.amber);
              }),
            ),
            if (review.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('"$review"')),
          ] else
            const Text("Még nincs értékelés."),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: értékelő űrlap megnyitása (ha még nem értékelte)
            },
            icon: const Icon(Icons.rate_review),
            label: const Text("Értékelés leadása"),
          )
        ],
      ),
    );
  }
}
