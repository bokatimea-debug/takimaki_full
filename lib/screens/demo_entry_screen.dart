import "package:flutter/material.dart";
import "../services/subscription_service.dart";
import "subscription_screen.dart";
import "favorites_screen.dart";
import "notifications_screen.dart";

class DemoEntryScreen extends StatelessWidget {
  const DemoEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Takimaki – DEMO belépő")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Gyors elérés (fejlesztői)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.subscriptions),
            title: const Text("Előfizetés – Megrendelő"),
            onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const SubscriptionScreen(role: UserRole.customer))),
          ),
          ListTile(
            leading: const Icon(Icons.subscriptions_outlined),
            title: const Text("Előfizetés – Szolgáltató"),
            onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const SubscriptionScreen(role: UserRole.provider))),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Kedvencek"),
            onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const FavoritesScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Értesítések (mock)"),
            onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const NotificationsScreen())),
          ),
        ],
      ),
    );
  }
}
