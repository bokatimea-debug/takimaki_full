// lib/screens/offers_screen.dart
import "package:flutter/material.dart";

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, Object?>?;
    final demo = [
      {"name": "Kiss Kft.", "rating": 4.8, "price": "12 000 Ft/óra"},
      {"name": "Tiszta Otthon Bt.", "rating": 4.6, "price": "11 500 Ft/óra"},
      {"name": "VillámSzerelő", "rating": 4.9, "price": "13 000 Ft/óra"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Elérhető szolgáltatók")),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: demo.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final it = demo[i];
          return ListTile(
            title: Text(it["name"] as String),
            subtitle: Text("★ ${(it["rating"] as double).toStringAsFixed(1)} • ${it["price"]}"),
            onTap: () => Navigator.pushNamed(context, "/chat", arguments: {"with": it["name"]}),
            trailing: FilledButton(
              onPressed: () => Navigator.pushNamed(context, "/chat", arguments: {"with": it["name"]}),
              child: const Text("Ajánlatkérés"),
            ),
          );
        },
      ),
    );
  }
}
