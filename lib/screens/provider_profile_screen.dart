// lib/screens/provider_profile_screen.dart
import "dart:typed_data";
import "package:flutter/material.dart";
import "../services/profile_store.dart";

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final store = ProfileStore.instance;

  @override
  Widget build(BuildContext context) {
    final p = store.provider;

    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltató profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profilkép + értékelés + sikeres munkák
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: p.photoBytes != null ? MemoryImage(p.photoBytes as Uint8List) : null,
              child: p.photoBytes == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 12),
            Text("⭐ ${p.rating.toStringAsFixed(1)} / 5.0", style: const TextStyle(fontSize: 18)),
            Text("${p.successCount} sikeres munka", style: const TextStyle(fontSize: 16)),
            if (p.bio.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(p.bio, textAlign: TextAlign.center),
            ],
            if (p.weekdayHours.isNotEmpty || p.weekendHours.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                [
                  if (p.weekdayHours.isNotEmpty) "Hétköznap: ${p.weekdayHours}",
                  if (p.weekendHours.isNotEmpty) "Hétvége: ${p.weekendHours}",
                ].join("   •   "),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 24),

            // Profil szerkesztése
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, "/provider/edit_profile");
                  setState(() {}); // visszatérés után frissít
                },
                child: const Text("Profil szerkesztése"),
              ),
            ),
            const SizedBox(height: 24),

            // Szolgáltatások
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, "/provider/services"),
                child: const Text("Szolgáltatások"),
              ),
            ),
            const SizedBox(height: 24),

            // Beérkezett ajánlatkérések
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/provider/requests"),
                child: const Text("Beérkezett ajánlatkérések"),
              ),
            ),
            const SizedBox(height: 12),

            // Üzenetek
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, "/provider/messages"),
                child: const Text("Üzenetek"),
              ),
            ),
            const Divider(height: 32),

            // Legutóbbi munkák – kompakt lista
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Legutóbbi munkáim",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            const ListTile(
              dense: true,
              visualDensity: VisualDensity(vertical: -2),
              title: Text("Nagytakarítás"),
              subtitle: Text("2025-08-28 • Teljesítve"),
            ),
            const ListTile(
              dense: true,
              visualDensity: VisualDensity(vertical: -2),
              title: Text("Vízszerelés"),
              subtitle: Text("2025-08-20 • Teljesítve"),
            ),
            const ListTile(
              dense: true,
              visualDensity: VisualDensity(vertical: -2),
              title: Text("Festés"),
              subtitle: Text("2025-08-15 • Lemondva"),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/provider/all_orders"),
              child: const Text("Összes megtekintése"),
            ),
          ],
        ),
      ),
    );
  }
}
