import "package:flutter/material.dart";
import "../utils/profile_photo_loader.dart";

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profilom")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ProfileAvatar(radius: 50),
            const SizedBox(height: 12),
            const Text("Megrendelő profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: ()=> Navigator.pushNamed(context, "/customer/edit_profile"),
              child: const Text("Profil szerkesztése"),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: ()=> Navigator.pushNamed(context, "/customer/orders"),
              child: const Text("Rendeléseim"),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: ()=> Navigator.pushNamed(context, "/customer/messages"),
              child: const Text("Üzenetek"),
            ),
          ],
        ),
      ),
    );
  }
}
