import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class StarRating extends StatelessWidget {
  final double rating; final double size;
  const StarRating({super.key, required this.rating, this.size = 22});
  @override Widget build(BuildContext context) {
    final full = rating.floor(); final hasHalf = (rating - full) >= 0.5;
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) {
      IconData icon; if (i < full) icon = Icons.star; else if (i == full && hasHalf) icon = Icons.star_half; else icon = Icons.star_border;
      return Icon(icon, size: size, color: const Color(0xFFFFC107));
    }));
  }
}

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDoc.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final data = snap.data!.data() ?? {};
        final name = (data["displayName"] as String?)?.trim();
        final bio  = (data["bio"] as String?)?.trim() ?? "";
        final photoUrl = (data["photoUrl"] as String?) ?? "";
        final stats = (data["stats"] as Map<String, dynamic>?) ?? {};
        final successes = (stats["provider_successful_orders"] as int?) ?? 0;
        final rating = (data["rating"] as Map<String, dynamic>?) ?? {};
        final avg = (rating["avg"] is num) ? (rating["avg"] as num).toDouble() : 0.0;
        final count = (rating["count"] as int?) ?? 0;

        return Scaffold(
          appBar: AppBar(title: const Text("Szolgáltatói profil")),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: (photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                  child: (photoUrl.isEmpty) ? const Icon(Icons.person, size: 48) : null,
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text(name?.isNotEmpty==true ? name! : "Felhasználó", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
              const SizedBox(height: 8),
              Center(child: StarRating(rating: count>0 ? avg : 0.0)),
              const SizedBox(height: 4),
              Center(child: Text((successes>=5 && count>0) ? "${avg.toStringAsFixed(1)} ($count)" : "Nincs értékelés")),
              const SizedBox(height: 12),
              if (bio.isNotEmpty) Center(child: Text(bio, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis)),
              const SizedBox(height: 8),
              Center(child: Text("Sikeres rendelések: $successes")),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center, spacing: 8, runSpacing: 8,
                children: [
                  OutlinedButton.icon(onPressed: ()=>Navigator.pushNamed(context,"/provider/edit_profile"), icon: const Icon(Icons.edit),  label: const Text("Profil szerkesztése")),
                  OutlinedButton.icon(onPressed: ()=>Navigator.pushNamed(context,"/provider/services"),     icon: const Icon(Icons.build), label: const Text("Szolgáltatásaim")),
                  OutlinedButton.icon(onPressed: ()=>Navigator.pushNamed(context,"/provider/requests"),     icon: const Icon(Icons.inbox), label: const Text("Ajánlatkérések")),
                  OutlinedButton.icon(onPressed: ()=>Navigator.pushNamed(context,"/provider/orders"),       icon: const Icon(Icons.list),  label: const Text("Rendeléseim")),
                  OutlinedButton.icon(onPressed: ()=>Navigator.pushNamed(context,"/provider/messages"),     icon: const Icon(Icons.chat),  label: const Text("Üzenetek")),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
