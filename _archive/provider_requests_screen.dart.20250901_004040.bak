import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({super.key});
  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen> {
  static const String kKey = "provider_requests";
  List<Map<String, dynamic>> _items = [];

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    String? raw = p.getString(kKey);
    if (raw == null || raw.isEmpty) {
      // minimál minta
      final samples = [
        {"id":"R1","service":"Általános takarítás","customer":"Kiss Anna","address":"Budapest, XI.","date":"2025-09-02","time":"10:00","status":"pending"},
        {"id":"R2","service":"Vízszerelés","customer":"Nagy Péter","address":"Budapest, XIII.","date":"2025-09-03","time":"14:30","status":"pending"},
      ];
      raw = json.encode(samples);
      await p.setString(kKey, raw);
    }
    _items = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    if (mounted) setState((){});
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(kKey, json.encode(_items));
  }

  Future<void> _reject(int i) async {
    _items.removeAt(i);
    await _save();
    if (mounted) setState((){});
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Beérkezett ajánlatkérések")),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        separatorBuilder: (_, __)=> const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final it = _items[i];
          final title = it["service"] ?? "";
          final sub = "${it["customer"] ?? ""} • ${it["address"] ?? ""} • ${it["date"] ?? ""} ${it["time"] ?? ""}";
          return Card(
            child: ListTile(
              title: Text(title),
              subtitle: Text(sub),
              onTap: () async {
                final res = await Navigator.pushNamed(context, "/provider/offer_reply", arguments: it);
                if (res == true) await _load();
              },
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: ()=> _reject(i),
                tooltip: "Elutasítás",
              ),
            ),
          );
        },
      ),
    );
  }
}
