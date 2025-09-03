import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/profile_photo_loader.dart';
import 'provider_edit_profile_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDoc.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final data = snap.data!.data() as Map<String, dynamic>? ?? {};
        final photoUrl = data['photoUrl'] as String?;
        return Scaffold(
          appBar: AppBar(title: const Text('Szolgáltatói profil')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: loadProfileImage(photoUrl),
                  child: photoUrl == null ? const Icon(Icons.person, size: 48) : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(data['displayName'] ?? 'Nincs név'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const ProviderEditProfileScreen()),
                  );
                  if (changed == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil frissítve')),
                    );
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Profil szerkesztése'),
              ),
            ],
          ),
        );
      },
    );
  }
}
