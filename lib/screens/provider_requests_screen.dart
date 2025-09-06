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
        stream: col.orderBy("createdAt", descending: true).snapshots(),
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final docs = s.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("Nincs beérkezett ajánlatkérés"));
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final doc = docs[i];
              final d = doc.data();
              return ListTile(
                title: Text(d["serviceName"]?.toString() ?? "Ajánlatkérés"),
                subtitle: Text(d["whenStr"]?.toString() ?? ""),
                onTap: () => Navigator.pushNamed(
                  context, "/provider/offer_reply",
                  arguments: {"requestId": doc.id, "initial": d},
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Törlés"),
                        content: const Text("Biztosan törlöd az ajánlatkérést?"),
                        actions: [
                          TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text("Mégse")),
                          ElevatedButton(onPressed: ()=>Navigator.pop(context,true), child: const Text("Törlés")),
                        ],
                      ),
                    );
                    if (ok==true) await doc.reference.delete();
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
