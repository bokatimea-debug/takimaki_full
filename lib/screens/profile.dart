import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

enum UserRole { customer, provider }

class ProfileScreen extends StatelessWidget {
  final UserRole role;
  const ProfileScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);
    final title = role==UserRole.provider ? "Szolgáltató profil" : "Megrendelő profil";

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDoc.snapshots(),
      builder: (c, s) {
        if (!s.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final d = s.data!.data() ?? {};
        final bio = (d["bio"] as String?) ?? "";
        final sub = (d["subscriptionActive"] as bool?) ?? false;
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(title),
                subtitle: Text((d["active"] as bool? ?? true) ? "Aktív" : "Inaktív"),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.workspace_premium, color: Colors.orange),
                title: const Text("Előfizetés (Store)"),
                subtitle: Text(sub ? "Aktív" : "Inaktív"),
              ),
              const SizedBox(height: 8),
              if (bio.isNotEmpty) Text("Bemutatkozás: $bio"),
            ],
          ),
        );
      },
    );
  }
}
