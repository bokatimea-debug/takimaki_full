import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});
  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  static const String kNewKey = "provider_services";
  static const List<String> kLegacyKeys = [
    "services",
    "provider_services_list",
    "my_services",
    "providerServices",
  ];

  List<Map<String, dynamic>> _items = [];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(kNewKey);

    if (raw == null || raw.isEmpty) {
      for (final lk in kLegacyKeys) {
        final r = prefs.getString(lk);
        if (r != null && r.isNotEmpty) {
          raw = r;
          await prefs.setString(kNewKey, r);
          break;
        }
      }
    }
    if (raw == null || raw.isEmpty) {
      raw = '[]';
    }

    try {
      _items = (json.decode(raw) as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      _items = [];
    }
    final ids = _items.map((item) => item['id']?.toString()).toSet();
    if (ids.length == 3 && ids.containsAll(const {'S1', 'S2', 'S3'})) {
      _items = [];
      await prefs.setString(kNewKey, '[]');
    }
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kNewKey, json.encode(_items));
  }

  Future<void> _delete(int index) async {
    final removed = _items.removeAt(index);
    await _save();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Törölve: ${removed["name"] ?? "szolgáltatás"}")),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltatásaim")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.pushNamed(
            context,
            "/provider/add_service",
          );
          if (res == true) await _load();
        },
        icon: const Icon(Icons.add),
        label: const Text("Új szolgáltatás"),
      ),
      body: _items.isEmpty
          ? const Center(child: Text("Nincs mentett szolgáltatás"))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final it = _items[i];
                final name = it["name"] ?? "";
                final price = it["price_fmt"] ?? "";
                final unit = it["unit"] ?? "";
                final dcount = (it["districts"] as List?)?.length ?? 0;
                final dates = (it["dates"] as List?)?.length ?? 0;
                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(
                      "$price $unit • Kerületek: $dcount • Napok: $dates",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final res = await Navigator.pushNamed(
                              context,
                              "/provider/add_service",
                              arguments: it,
                            );
                            if (res == true) await _load();
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => _delete(i),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
