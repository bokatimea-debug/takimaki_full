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

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDoc.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final data = snap.data!.data() ?? {};
        final active = (data["active"] as bool?) ?? true;
        final bio = (data["bio"] as String?) ?? "";
        final subscriptionActive = (data["subscriptionActive"] as bool?) ?? false;

        return Scaffold(
          appBar: AppBar(title: Text(role == UserRole.customer ? "Megrendelő profil" : "Szolgáltató profil")),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: CircleAvatar(child: const Icon(Icons.person)),
                title: Text(role == UserRole.customer ? "Megrendelő profil" : "Szolgáltató profil"),
                subtitle: Text(active ? "Aktív" : "Inaktív"),
              ),
              const Divider(),
              if (role == UserRole.provider) _providerControls() else _customerControls(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.workspace_premium, color: Colors.orange),
                title: const Text("Előfizetés (Google/Apple): 3000 Ft/hó"),
                subtitle: Text(subscriptionActive ? "Aktív" : "Inaktív"),
              ),
              const SizedBox(height: 12),
              if (bio.isNotEmpty) Text("Bemutatkozás: $bio"),
            ],
          ),
        );
      },
    );
  }

  Widget _customerControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Megrendelő beállítások", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("A megrendelő profilt nem lehet felfüggeszteni/kizárni.", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _providerControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Szolgáltató státusz & szabályok", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("Szabályok: 10 pont → 14 nap felfüggesztés; 2× no-show → 14 nap felfüggesztés; 5× 1★ → felfüggesztés.",
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
