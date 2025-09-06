import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class ProviderServicesScreen extends StatelessWidget {
  const ProviderServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final col = FirebaseFirestore.instance.collection("users").doc(uid).collection("services");

    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltatásaim")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: col.orderBy("updatedAt", descending: true).snapshots(),
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final docs = s.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("Nincs felvitt szolgáltatás"));
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final d = docs[i];
              final m = d.data();
              return ListTile(
                title: Text(m["name"]?.toString() ?? "Szolgáltatás"),
                subtitle: Text("Ár: ${m["price"] ?? "-"} Ft – ${m["duration"] ?? "-"} perc"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    "/provider/add_service",
                    arguments: {"serviceId": d.id, "initial": m},
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "/provider/add_service"),
        child: const Icon(Icons.add),
      ),
    );
  }
}
