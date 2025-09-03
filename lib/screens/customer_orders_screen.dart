import "package:flutter/material.dart";
import "customer_order_detail_screen.dart";

class CustomerOrdersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> orders; // illeszd a Firestore-os forrásodra
  const CustomerOrdersScreen({super.key, this.orders = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rendeléseim")),
      body: ListView.separated(
        itemCount: orders.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final o = orders[i];
          final rating = (o["rating"] as num?)?.toDouble();

          return ListTile(
            title: Text(o["title"] ?? "Rendelés"),
            subtitle: Text(o["dateStr"] ?? ""),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => CustomerOrderDetailScreen(order: o),
              ));
            },
            trailing: TextButton.icon(
              onPressed: () {
                // TODO: értékelő űrlap/oldal megnyitása (ha még nem értékelte)
              },
              icon: const Icon(Icons.star_rate),
              label: Text(rating == null ? "Értékelés" : "Megnyitás"),
            ),
          );
        },
      ),
    );
  }
}
