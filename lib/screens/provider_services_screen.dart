import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "dart:convert";

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});
  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  List<Map<String, dynamic>> _items = [];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("provider_services") ?? "[]";
    _items = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    if (mounted) setState((){});
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("provider_services", json.encode(_items));
  }

  Future<void> _delete(int index) async {
    _items.removeAt(index);
    await _save();
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
      appBar: AppBar(title: const Text("Szolgáltatásaim")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.pushNamed(context, "/provider/add_service");
          if (res == true) await _load();
        },
        icon: const Icon(Icons.add),
        label: const Text("Új szolgáltatás"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        separatorBuilder: (_, __)=> const SizedBox(height: 8),
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
              subtitle: Text("$price $unit • Kerületek: $dcount • Napok: $dates"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () async {
                    // szerkesztés ugyanazzal a képernyővel
                    final res = await Navigator.pushNamed(context, "/provider/add_service", arguments: it);
                    if (res == true) await _load();
                  }, icon: const Icon(Icons.edit)),
                  IconButton(onPressed: ()=> _delete(i), icon: const Icon(Icons.close))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
