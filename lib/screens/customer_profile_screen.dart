import "package:flutter/material.dart";

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ÁTMENETI: dummy adatok
    const photoUrl = "";
    const name = "Megrendelő (stub)";
    const bio = "Rövid bemutatkozás – átmeneti stub.";
    const successes = 3;

    return Scaffold(
      appBar: AppBar(title: const Text("Profilom (stub)")),
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
            spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_circle), label: const Text("Új rendelés")),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.list), label: const Text("Rendeléseim")),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat), label: const Text("Üzenetek")),
            ],
          ),
        ],
      ),
    );
  }
}
