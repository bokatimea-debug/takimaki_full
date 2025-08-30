// lib/screens/customer_profile_screen.dart
import "dart:typed_data";
import "package:flutter/material.dart";
import "../services/profile_store.dart";

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final store = ProfileStore.instance;

  @override
  Widget build(BuildContext context) {
    final c = store.customer;

    return Scaffold(
      appBar: AppBar(title: const Text("Megrendelő profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: c.photoBytes != null ? MemoryImage(c.photoBytes as Uint8List) : null,
              child: c.photoBytes == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 12),
            Text("⭐ ${c.rating.toStringAsFixed(1)} / 5.0", style: const TextStyle(fontSize: 18)),
            Text("${c.successCount} sikeres rendelés", style: const TextStyle(fontSize: 16)),
            if (c.bio.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(c.bio, textAlign: TextAlign.center),
            ],
            if (c.weekdayHours.isNotEmpty || c.weekendHours.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                [
                  if (c.weekdayHours.isNotEmpty) "Hétköznap: ${c.weekdayHours}",
                  if (c.weekendHours.isNotEmpty) "Hétvége: ${c.weekendHours}",
                ].join("   •   "),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, "/customer/edit_profile");
                  setState(() {});
                },
                child: const Text("Profil szerkesztése"),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, "/customer/new_order"),
                child: const Text("Új rendelés leadása"),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, "/customer/messages"),
                child: const Text("Üzenetek"),
              ),
            ),
            const Divider(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Legutóbbi rendeléseim",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            const ListTile(
              dense: true,
              visualDensity: VisualDensity(vertical: -2),
              title: Text("Takarítás"),
              subtitle: Text("2025-08-29 • Teljesítve"),
            ),
            const ListTile(
              dense: true,
              visualDensity: VisualDensity(vertical: -2),
              title: Text("Villanyszerelés"),
              subtitle: Text("2025-08-20 • Lemondva"),
            ),
            const ListTile(
              dense: true,
              visualDensity: VisualDensity(vertical: -2),
              title: Text("Nagytakarítás"),
              subtitle: Text("2025-08-05 • Teljesítve"),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/customer/orders"),
              child: const Text("Összes rendelés megtekintése"),
            ),
          ],
        ),
      ),
    );
  }
}
