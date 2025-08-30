import "dart:typed_data";
import "package:flutter/material.dart";
import "../services/profile_store.dart";

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ProfileStore.instance.customer;

    Widget avatar() {
      final Uint8List? bytes = c.photoBytes;
      if (bytes == null) {
        return const CircleAvatar(radius: 44, child: Icon(Icons.person, size: 44));
      }
      return CircleAvatar(radius: 44, backgroundImage: MemoryImage(bytes));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Megrendelő profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            avatar(),
            const SizedBox(height: 8),
            if (c.bio.isNotEmpty) Text(c.bio, textAlign: TextAlign.center),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, "/customer/profile/edit")
                    .then((_) => (context as Element).markNeedsBuild()),
                child: const Text("Profil szerkesztése"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, "/customer/order/new"),
                child: const Text("Új rendelés leadása"),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, "/customer/messages"),
              child: const Text("Üzenetek"),
            ),
            const Spacer(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Legutóbbi rendeléseim", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("• Takarítás – Teljesítve\n• Villanyszerelés – Lemondva\n• Nagytakarítás – Teljesítve"),
            ),
          ],
        ),
      ),
    );
  }
}
