import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "../utils/profile_photo_loader.dart";
import "../widgets/star_rating.dart";

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDoc.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final data = snap.data?.data() ?? {};
        final displayName = (data["displayName"] as String?)?.trim();
        final bio = (data["bio"] as String?)?.trim() ?? "";
        final stats = (data["stats"] as Map<String, dynamic>?) ?? {};
        final successes = (stats["customer_successful_orders"] as int?) ?? 0;

        final rating = (data["rating"] as Map<String, dynamic>?) ?? {};
        final avg = (rating["avg"] is num) ? (rating["avg"] as num).toDouble() : 0.0;
        final count = (rating["count"] as int?) ?? 0;

        return FutureBuilder<String?>(
          future: loadProfilePhotoUrl(uid),
          builder: (context, photoSnap) {
            final photoUrl = photoSnap.data;
            return Scaffold(
              appBar: AppBar(title: const Text("Profilom")),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                      child: (photoUrl == null || photoUrl.isEmpty)
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      displayName?.isNotEmpty == true ? displayName! : "Felhasználó",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Center(child: StarRating(rating: count > 0 ? avg : 0.0, size: 22)),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      (successes >= 5 && count > 0) ? "${avg.toStringAsFixed(1)} (${count})" : "Nincs értékelés",
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ),

                  const SizedBox(height: 12),
                  if (bio.isNotEmpty)
                    Center(
                      child: Text(
                        bio,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Center(child: Text("Sikeres rendelések: $successes")),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, "/customer/new_order"),
                        icon: const Icon(Icons.add_circle),
                        label: const Text("Új rendelés"),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, "/customer/orders"),
                        icon: const Icon(Icons.list),
                        label: const Text("Rendeléseim"),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, "/customer/messages"),
                        icon: const Icon(Icons.chat),
                        label: const Text("Üzenetek"),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, "/customer/edit_profile"),
                        icon: const Icon(Icons.edit),
                        label: const Text("Profil szerkesztése"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
