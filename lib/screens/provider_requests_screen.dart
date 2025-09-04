import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class ProviderRequestsScreen extends StatelessWidget {
  const ProviderRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection("requests");

    return Scaffold(
      appBar: AppBar(title: const Text("Beérkezett ajánlatkérések")),
      body: StreamBuilder<QuerySnapshot>(
        stream: col.orderBy("createdAt", descending: true).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("Nincs beérkezett ajánlatkérés"));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final d = doc.data() as Map<String, dynamic>? ?? {};
              final title = d["serviceName"] ?? "Ajánlatkérés";
              final when = d["whenStr"] ?? "";

              return ListTile(
                title: Text(title),
                subtitle: Text(when),
                onTap: () async {
                  final res = await Navigator.pushNamed(
                    context,
                    "/provider/offer_reply",
                    arguments: {"requestId": doc.id, "initial": d},
                  );
                  if (res is Map && res["ok"] == true) {
                    // noop – a visszatérő oldal intézi a frissítést
                  }
                },
                trailing: Wrap(spacing: 8, children: [
                  TextButton(
                    onPressed: () {
                      // gyors elfogadás helye – később: Cloud Function / Firestore update
                    },
                    child: const Text("Gyors elfogadás"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Törlés"),
                          content: const Text("Biztosan törlöd az ajánlatkérést?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Mégse")),
                            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Törlés")),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await doc.reference.delete();
                      }
                    },
                  ),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
