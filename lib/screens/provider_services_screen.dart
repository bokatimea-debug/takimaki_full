import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});
  @override State<ProviderServicesScreen> createState() => _S();
}
class _S extends State<ProviderServicesScreen> {
  List<Map<String, dynamic>> _items = [];
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('provider_services') ?? '[]';
    setState(()=> _items = (json.decode(raw) as List).cast<Map<String, dynamic>>());
  }
  Future<void> _delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    _items.removeWhere((e)=> e['id'] == id);
    await prefs.setString('provider_services', json.encode(_items));
    setState((){});
  }
  Future<void> _addOrEdit([Map<String, dynamic>? item]) async {
    final ok = await Navigator.pushNamed(context, '/provider/add_service', arguments: item) as bool?;
    if (ok == true) await _load();
  }
  String _roman(int n) => const ['','I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII','XIII','XIV','XV','XVI','XVII','XVIII','XIX','XX','XXI','XXII','XXIII'][n];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltatásaim')),
      floatingActionButton: FloatingActionButton.extended(onPressed: ()=> _addOrEdit(), icon: const Icon(Icons.add), label: const Text('Új szolgáltatás')),
      body: _items.isEmpty
        ? Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cleaning_services, size: 56, color: Colors.black54),
              const SizedBox(height: 8),
              const Text('Még nincs felvett szolgáltatás.\nNyomd meg az Új szolgáltatás gombot.', textAlign: TextAlign.center),
            ]),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i){
              final it = _items[i];
              final districts = (it['districts'] as List?)?.cast<int>() ?? <int>[];
              final ds = districts.map(_roman).join(', ');
              final unit = (it['unit'] ?? '') as String;
              final priceFmt = (it['price_fmt'] ?? '') as String;
              return Card(
                child: ListTile(
                  title: Text(it['name'] ?? ''),
                  subtitle: Text('Ár: $priceFmt $unit\nKerületek: $ds'),
                  isThreeLine: true,
                  trailing: Wrap(spacing: 4, children: [
                    IconButton(tooltip: 'Szerkesztés', onPressed: ()=> _addOrEdit(it), icon: const Icon(Icons.edit)),
                    IconButton(tooltip: 'Törlés', onPressed: ()=> _delete(it['id']), icon: const Icon(Icons.close)),
                  ]),
                ),
              );
            },
          ),
    );
  }
}
