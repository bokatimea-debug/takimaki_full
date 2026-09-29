import "dart:convert";

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
  String _name = "";
  String _bio = "";
  double _rating = 0;
  int _ratingCount = 0;
  List<String> _services = [];
  int _districtCount = 0;
  String _availability = "09:00–18:00";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final p = await ProfilePhotoLoader.loadAny();
    if (!mounted) return;
    setState(() {
      _photo = p;
      _success = prefs.getInt("provider_success_count") ?? 0;
      final first =
          prefs.getString("provider_first_name") ??
          prefs.getString("customer_first_name") ??
          "";
      final last =
          prefs.getString("provider_last_name") ??
          prefs.getString("customer_last_name") ??
          "";
      _name = [last, first].where((e) => e.trim().isNotEmpty).join(" ");
      _bio = prefs.getString("provider_bio") ?? "";
      _rating = prefs.getDouble("provider_rating") ?? 0;
      _ratingCount = prefs.getInt("provider_rating_count") ?? 0;
      final rawServices = prefs.getString("provider_services") ?? "[]";
      try {
        final decoded = (json.decode(rawServices) as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        _services = decoded
            .map((item) => item["name"]?.toString() ?? "")
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();
        _districtCount = decoded
            .expand((item) => (item["districts"] as List? ?? const []))
            .toSet()
            .length;
      } catch (_) {
        _services = [];
        _districtCount = 0;
      }
      final from = prefs.getString("provider_wd_from") ?? "09:00";
      final to = prefs.getString("provider_wd_to") ?? "18:00";
      _availability = "$from–$to";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Szolgáltató profil"),
        actions: [
          IconButton(
            tooltip: "Beállítások",
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: "Szerepváltás",
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/role_select'),
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
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
            Center(
              child: Text(
                _name.isEmpty ? "Szolgáltató" : _name,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (_bio.isNotEmpty) ...[
              const SizedBox(height: 6),
              Center(child: Text(_bio, textAlign: TextAlign.center)),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 20, color: Color(0xFFFF8C42)),
                Text(
                  _success < 5 || _rating == 0
                      ? " 5 munka után látható"
                      : " ${_rating.toStringAsFixed(1)} ($_ratingCount)",
                ),
                const SizedBox(width: 18),
                Text("$_success sikeres munka"),
              ],
            ),
            if (_services.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(_services.join(" • "), textAlign: TextAlign.center),
              ),
            ],
            const SizedBox(height: 6),
            Center(
              child: Text(
                "${_districtCount == 23 ? 'Egész Budapest' : '$_districtCount kiválasztott kerület'} • $_availability",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
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
              onPressed: () =>
                  Navigator.pushNamed(context, "/provider/services"),
              child: const Text("Szolgáltatásaim"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, "/provider/requests"),
              child: const Text("Beérkezett ajánlatkérések"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, "/provider/messages"),
              child: const Text("Üzenetek"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, "/provider/all_orders"),
              child: const Text("Összes rendelés"),
            ),
          ],
        ),
      ),
    );
  }
}
