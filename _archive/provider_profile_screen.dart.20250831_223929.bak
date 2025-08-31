import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../utils/profile_photo_loader.dart";
import "dart:convert";

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});
  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  double _avg = 0;
  int _reviews = 0;
  int _success = 0;
  String _name = "Szolgáltató";

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString("provider_name") ?? _name;

    // értékelések (mock vagy tárolt)
    final jsonStr = prefs.getString("provider_reviews") ?? "[]";
    final list = (json.decode(jsonStr) as List).cast<Map>();
    _reviews = list.length;
    if (_reviews > 0) {
      _avg = list.map((e) => (e["stars"] ?? 0) as num).fold<num>(0, (a,b)=>a+b) / _reviews;
    } else {
      _avg = 0;
    }

    // sikeres rendelések száma (mock vagy tárolt)
    _success = prefs.getInt("provider_success_count") ?? 0;

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final starText = _reviews == 0 ? "Nincs értékelés" : "${_avg.toStringAsFixed(1)} ★ ($_reviews)";
    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltatói profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: ProfileAvatar(radius: 50)),
            const SizedBox(height: 12),
            Center(child: Text(_name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Center(child: Text(starText)),
            const SizedBox(height: 4),
            Center(child: Text("Sikeres rendelések: $_success")),

            const SizedBox(height: 16),
            FilledButton(
              onPressed: ()=> Navigator.pushNamed(context, "/provider/edit_profile").then((_){ _load(); }),
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
