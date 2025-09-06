import "package:flutter/material.dart";

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ÁTMENETI: dummy adatok, hogy a build menjen
    const photoUrl = ""; // ha üres, ikon jelenik meg
    const name = "Szolgáltató (stub)";
    const bio = "Rövid bemutatkozás – átmeneti stub.";
    const successes = 2;

    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltatói profil (stub)")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          if (bio.isNotEmpty) Center(child: Text(bio, textAlign: TextAlign.center)),
          const SizedBox(height: 8),
          Center(child: Text("Sikeres rendelések: $successes")),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.build), label: const Text("Szolgáltatásaim")),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.inbox), label: const Text("Ajánlatkérések")),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat), label: const Text("Üzenetek")),
            ],
          ),
        ],
      ),
    );
  }
}
