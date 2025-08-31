import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ProviderAllOrdersScreen extends StatefulWidget {
  const ProviderAllOrdersScreen({super.key});
  @override
  State<ProviderAllOrdersScreen> createState() => _ProviderAllOrdersScreenState();
}

class _ProviderAllOrdersScreenState extends State<ProviderAllOrdersScreen> {
  static const String kKey = "provider_orders";
  List<Map<String, dynamic>> _items = [];

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    String? raw = p.getString(kKey);
    if (raw == null || raw.isEmpty) {
      // minta adatok értékeléssel
      final samples = [
        {"id":"O1","service":"Általános takarítás","when":"2025-08-20 09:00","rating":5},
        {"id":"O2","service":"Vízszerelés","when":"2025-08-22 14:30","rating":4},
        {"id":"O3","service":"Nagytakarítás","when":"2025-08-25 10:00","rating":3},
      ];
      raw = json.encode(samples);
      await p.setString(kKey, raw);
    }
    _items = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    if (mounted) setState((){});
  }

  @override
  void initState() { super.initState(); _load(); }

  Widget _stars(int n){
    n = n.clamp(0,5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i){
        final filled = i < n;
        return Icon(filled ? Icons.star : Icons.star_border, color: Colors.amber);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Összes rendelés")),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        separatorBuilder: (_, __)=> const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final it = _items[i];
          final title = it["service"] ?? "";
          final when  = it["when"] ?? "";
          final rating = (it["rating"] ?? 0) as int;
          return Card(
            child: ListTile(
              title: Text(title),
              subtitle: Text(when),
              trailing: _stars(rating),
            ),
          );
        },
      ),
    );
  }
}
