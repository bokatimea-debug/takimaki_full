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
  String _name = "Szolgáltató";
  int _success = 0;
  List<Map<String, dynamic>> _reviews = [];

  double get _avg => _reviews.isEmpty
      ? 0
      : _reviews.map((e)=> (e["stars"] ?? 0) as num).fold<num>(0,(a,b)=>a+b) / _reviews.length;

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _name = p.getString("provider_name") ?? _name;
    _success = p.getInt("provider_success_count") ?? 0;
    final rev = p.getString("provider_reviews") ?? "[]";
    _reviews = (json.decode(rev) as List).cast<Map<String,dynamic>>();
    if (mounted) setState((){});
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final starText = _reviews.isEmpty ? "Nincs értékelés" : "${_avg.toStringAsFixed(1)} ★ (${_reviews.length})";
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
            const SizedBox(height: 16),

            // Értékelések blokk (rövid lista)
            if (_reviews.isNotEmpty) const Text("Legutóbbi értékelések", style: TextStyle(fontWeight: FontWeight.bold)),
            if (_reviews.isNotEmpty) const SizedBox(height: 8),
            if (_reviews.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: _reviews.length.clamp(0, 3),
                  separatorBuilder: (_, __)=> const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final r = _reviews[_reviews.length - 1 - i]; // legutóbbi elől
                    final stars = (r["stars"] ?? 0) as int;
                    final text = (r["text"] ?? "") as String;
                    return ListTile(
                      leading: Text("★"*stars, style: const TextStyle(fontSize: 16)),
                      title: Text(text.isEmpty ? "Nincs szöveg" : text),
                    );
                  },
                ),
              )
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Teszt értékelés hozzáadása",
        onPressed: () async {
          final p = await SharedPreferences.getInstance();
          final raw = p.getString("provider_reviews") ?? "[]";
          final list = (json.decode(raw) as List).cast<Map<String,dynamic>>();
          list.add({"stars": 5, "text": "Gyors és precíz munka."});
          await p.setString("provider_reviews", json.encode(list));
          _load();
        },
        child: const Icon(Icons.star),
      ),
    );
  }
}
