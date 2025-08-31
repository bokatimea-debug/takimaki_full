import "package:flutter/material.dart";
import "../utils/profile_photo_loader.dart";

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});
  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  void _refreshAfter() => setState((){});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profilom")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: ProfileAvatar(radius: 50)),
            const SizedBox(height: 12),
            const Center(child: Text("Megrendelő profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: ()=> Navigator.pushNamed(context, "/customer/edit_profile").then((_){ _refreshAfter(); }),
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
