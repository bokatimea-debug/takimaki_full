import "package:flutter/material.dart";

class ProviderRequestsScreen extends StatelessWidget {
  const ProviderRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ÁTMENETI: dummy adatok, hogy a build menjen
    final docs = List.generate(5, (i) => {
      "id": "req_$i",
      "serviceName": "Ajánlatkérés #$i",
      "whenStr": "2025-09-0${(i%9)+1} 10:00",
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Beérkezett ajánlatkérések")),
      body: ListView.separated(
        itemCount: docs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final d = docs[i];
          return ListTile(
            title: Text(d["serviceName"] as String),
            subtitle: Text(d["whenStr"] as String),
            onTap: () async {
              final res = await Navigator.pushNamed(
                context,
                "/provider/offer_reply",
                arguments: {"requestId": d["id"], "initial": d},
              );
              // no-op
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}
