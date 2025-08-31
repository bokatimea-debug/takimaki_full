import "package:flutter/material.dart";
import "../utils/profile_photo_loader.dart";

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltatói profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ProfileAvatar(radius: 50),
            const SizedBox(height: 12),
            const Text("Szolgáltató profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: ()=> Navigator.pushNamed(context, "/provider/edit_profile"),
                child: const Text("Profil szerkesztése"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: ()=> Navigator.pushNamed(context, "/provider/services"),
                child: const Text("Szolgáltatásaim"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: ()=> Navigator.pushNamed(context, "/provider/requests"),
                child: const Text("Beérkezett ajánlatkérések"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: ()=> Navigator.pushNamed(context, "/provider/messages"),
                child: const Text("Üzenetek"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: ()=> Navigator.pushNamed(context, "/provider/all_orders"),
                child: const Text("Összes rendelés"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
