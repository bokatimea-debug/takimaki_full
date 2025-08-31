import 'package:flutter/material.dart';

class ProviderAllOrdersScreen extends StatelessWidget {
  const ProviderAllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Backendből betölteni a szolgáltatásokat + értékeléseket
    final orders = [
      {"service": "Apartman takarítás", "review": 4},
      {"service": "Karbantartás", "review": 5},
      {"service": "Villanyszerelés", "review": 3},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Összes rendelés")),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final item = orders[index];
          return ListTile(
            title: Text(item["service"].toString()),
            subtitle: Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < (item["review"] as int)
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
