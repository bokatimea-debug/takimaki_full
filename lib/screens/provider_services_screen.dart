import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'provider_add_service_screen.dart';

class ProviderServicesScreen extends StatelessWidget {
  const ProviderServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final col = FirebaseFirestore.instance.collection('users').doc(uid).collection('services');

    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltatásaim')),
      body: StreamBuilder<QuerySnapshot>(
        stream: col.orderBy('name').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nincs felvett szolgáltatás. Koppints a + gombra.'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(d['name'] ?? ''),
                subtitle: Text('${(d['price'] ?? 0)} Ft • ${(d['duration'] ?? 60)} perc'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ProviderAddServiceScreen(serviceId: docs[i].id, initial: d))),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Törlés'),
                            content: const Text('Biztosan törlöd a szolgáltatást?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Mégse')),
                              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Törlés')),
                            ],
                          ),
                        );
                        if (ok == true) await col.doc(docs[i].id).delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProviderAddServiceScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
