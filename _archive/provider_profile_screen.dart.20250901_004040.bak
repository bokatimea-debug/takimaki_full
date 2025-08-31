import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../utils/profile_photo_loader.dart";

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});
  @override
  State<ProviderProfileScreen> createState() => _S();
}

class _S extends State<ProviderProfileScreen> {
  ImageProvider? _photo;
  int _success = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final p = await ProfilePhotoLoader.loadAny();
    setState(() {
      _photo = p;
      _success = prefs.getInt("provider_success_count") ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltató profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ProfileAvatar(
                background: _photo,
                radius: 48,
                childWhenEmpty: const Icon(Icons.person, size: 48),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text("Sikeres rendelések: $_success")),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await Navigator.pushNamed(context, "/provider/edit_profile");
                // visszatéréskor frissítjük a fotót
                await _load();
              },
              child: const Text("Profil szerkesztése"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: ()=> Navigator.pushNamed(context, "/provider/services"),
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
          ],
        ),
      ),
    );
  }
}
