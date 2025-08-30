import "dart:typed_data";
import "package:flutter/material.dart";
import "../services/profile_store.dart";

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = ProfileStore.instance.provider;

    Widget avatar() {
      final Uint8List? bytes = p.photoBytes;
      if (bytes == null) {
        return const CircleAvatar(radius: 44, child: Icon(Icons.person, size: 44));
      }
      return CircleAvatar(radius: 44, backgroundImage: MemoryImage(bytes));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltató profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            avatar(),
            const SizedBox(height: 8),
            if (p.bio.isNotEmpty) Text(p.bio, textAlign: TextAlign.center),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, "/provider/profile/edit")
                    .then((_) => (context as Element).markNeedsBuild()),
                child: const Text("Profil szerkesztése"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, "/provider/services"),
                child: const Text("Szolgáltatásaim"),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, "/provider/requests"),
              child: const Text("Beérkezett ajánlatkérések"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, "/provider/messages"),
              child: const Text("Üzenetek"),
            ),
            const Spacer(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Legutóbbi munkáim", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("• Példa munka 1\n• Példa munka 2\n• Példa munka 3"),
            ),
          ],
        ),
      ),
    );
  }
}
