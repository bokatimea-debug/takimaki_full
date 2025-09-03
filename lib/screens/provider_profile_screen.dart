import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDoc.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final data = (snap.data!.data() as Map<String, dynamic>? ?? {});
        final photoUrl = (data["photoUrl"] as String?) ?? "";
        final displayName = (data["displayName"] as String?) ?? "Nincs név";
        final bio = (data["bio"] as String?) ?? "";

        // Sikeres teljesítések (spec: providers)
        final stats = (data["stats"] as Map<String, dynamic>?) ?? {};
        final successful = (stats["provider_successful_orders"] as int?) ?? 0;

        // Értékelés – csak 5 teljesítés után mutatjuk az átlagot; csillagkomponens mindig látszik
        double ratingAvg = 0.0;
        int ratingCount = 0;
        if (data["rating"] is Map) {
          final r = data["rating"] as Map;
          ratingAvg = ((r["avg"] ?? 0) as num).toDouble();
          ratingCount = (r["count"] ?? 0) as int;
        } else {
          // fallback kulcsok
          ratingAvg = ((data["avgRating"] ?? 0) as num).toDouble();
          ratingCount = (data["reviewCount"] ?? 0) as int;
        }
        final showAvg = ratingCount >= 5 && ratingAvg > 0;

        // Előfizetés státusz chip (provider)
        final subs = (data["subscriptions"] as Map<String, dynamic>?) ?? {};
        final prov = (subs["provider"] as Map<String, dynamic>?) ?? {};
        final isActive = (prov["isActive"] as bool?) ?? false;
        DateTime? activeUntil;
        final ts = prov["activeUntil"];
        if (ts is Timestamp) activeUntil = ts.toDate();

        String subLabel;
        Color? subColor;
        final now = DateTime.now();
        final activeOk = isActive && (activeUntil == null || activeUntil!.isAfter(now));
        if (activeOk) {
          subLabel = "Aktív előfizetés";
          subColor = Colors.green.shade600;
        } else if (successful >= 1) {
          subLabel = "Lejárt előfizetés";
          subColor = Colors.orange.shade700;
        } else {
          subLabel = "Ingyenes időszak";
          subColor = Colors.blueGrey.shade600;
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Szolgáltatói profil")),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: (photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty ? const Icon(Icons.person, size: 48) : null,
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text(displayName, style: Theme.of(context).textTheme.titleMedium)),
              const SizedBox(height: 8),

              // Értékelés sor
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStars(showAvg ? ratingAvg : 0),
                  const SizedBox(width: 8),
                  Text(
                    showAvg ? "${ratingAvg.toStringAsFixed(1)} (${ratingCount})"
                            : "—",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Center(
                child: Chip(
                  label: Text(subLabel, style: const TextStyle(color: Colors.white)),
                  backgroundColor: subColor,
                ),
              ),

              const SizedBox(height: 12),
              // Sikeres rendelések
              Center(
                child: Text("Sikeres rendelések: $successful",
                    style: Theme.of(context).textTheme.bodyMedium),
              ),

              const SizedBox(height: 12),
              // Bemutatkozás (max 3 sor)
              if (bio.isNotEmpty) ...[
                Text("Bemutatkozás",
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  bio,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),
              // Gyors menü – semleges (nem zöld) gombok, csak interakciókor színez a rendszer
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _quickButton(context, Icons.map, "Működési terület", () {
                    // Navigator.pushNamed(context, "/provider/area");
                  }),
                  _quickButton(context, Icons.build, "Szolgáltatásaim", () {
                    // Navigator.pushNamed(context, "/provider/services");
                  }),
                  _quickButton(context, Icons.inbox, "Ajánlatkérések", () {
                    // Navigator.pushNamed(context, "/provider/requests");
                  }),
                  _quickButton(context, Icons.chat_bubble, "Üzenetek", () {
                    // Navigator.pushNamed(context, "/messages");
                  }),
                  _quickButton(context, Icons.list_alt, "Rendelések", () {
                    // Navigator.pushNamed(context, "/provider/orders");
                  }),
                  _quickButton(context, Icons.star, "Értékelések", () {
                    // Navigator.pushNamed(context, "/provider/reviews");
                  }),
                  _quickButton(context, Icons.notifications, "Értesítések", () {
                    // Navigator.pushNamed(context, "/notifications");
                  }),
                  _quickButton(context, Icons.workspace_premium, "Előfizetés", () {
                    // Navigator.pushNamed(context, "/subscription");
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildStars(double rating) {
    // 0..5 csillag, félcsillag támogatás
    int full = rating.floor();
    bool hasHalf = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (i == full && hasHalf) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }

  static Widget _quickButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
