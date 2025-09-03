import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDoc.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        final photoUrl = data['photoUrl'] ?? '';
        final name = data['displayName'] ?? 'Név hiányzik';
        final bio = data['bio'] ?? '';
        final successes = data['stats']?['provider_successful_orders'] ?? 0;

        return Scaffold(
          appBar: AppBar(title: const Text('Szolgáltatói profil (simple)')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: photoUrl != '' ? NetworkImage(photoUrl) : null,
                  child: photoUrl == '' ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (bio != '') ...[
                  const SizedBox(height: 8),
                  Text(bio, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 8),
                Text('Sikeres rendelések: $successes'),
              ],
            ),
          ),
        );
      },
    );
  }
}
