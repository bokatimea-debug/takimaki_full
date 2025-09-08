import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class ProviderRequestsScreen extends StatelessWidget {
  const ProviderRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection("requests");

    return Scaffold(
      appBar: AppBar(title: const Text("Beérkezett ajánlatkérések")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: col.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("Nincsenek beérkezett ajánlatkérések."));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i].data();
              return ListTile(
                title: Text(d["serviceName"] ?? "Ajánlatkérés"),
                subtitle: Text(d["whenStr"] ?? ""),
                onTap: () {
                  Navigator.pushNamed(context, "/provider/offer_reply",
                      arguments: {"requestId": docs[i].id, "initial": d});
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    docs[i].reference.delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
