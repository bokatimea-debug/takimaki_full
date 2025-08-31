import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../utils/profile_photo_loader.dart";

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});
  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  String _name = "Szolgáltató";
  int _success = 0;

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _name = p.getString("provider_name") ?? _name;
    _success = p.getInt("provider_success_count") ?? 0;
    if (mounted) setState((){});
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltatói profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: ProfileAvatar(radius: 52)),
            const SizedBox(height: 12),
            Center(child: Text(_name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 4),
            Center(child: Text("Sikeres rendelések: $_success")),
            const SizedBox(height: 16),

            FilledButton(
              onPressed: ()=> Navigator.pushNamed(context, "/provider/edit_profile").then((_){ _load(); }),
              child: const Text("Profil szerkesztése"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: ()=> Navigator.pushNamed(context, "/provider/services").then((_){ _load(); }),
              child: const Text("Szolgáltatásaim"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: ()=> Navigator.pushNamed(context, "/provider/requests"),
              child: const Text("Beérkezett ajánlatkérések"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: ()=> Navigator.pushNamed(context, "/provider/messages"),
              child: const Text("Üzenetek"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: ()=> Navigator.pushNamed(context, "/provider/all_orders"),
              child: const Text("Összes rendelés"),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
