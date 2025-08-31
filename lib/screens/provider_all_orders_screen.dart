import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderAllOrdersScreen extends StatefulWidget {
  const ProviderAllOrdersScreen({super.key});
  @override State<ProviderAllOrdersScreen> createState() => _S();
}
class _S extends State<ProviderAllOrdersScreen> {
  List<Map<String, dynamic>> _items = [];
  @override void initState(){ super.initState(); _load(); }
  Future<void> _seedIfEmpty() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('provider_orders');
    if (raw == null || raw.isEmpty || raw == '[]') {
      final demo = [
        {'id':'o1','service':'Általános takarítás','address':'1138 Budapest, Váci út 99.','date':'2025-08-20','time':'10:00','price':'14 000 Ft','rating':5,'comment':'Szuper munka, köszönöm!'},
        {'id':'o2','service':'Vízszerelés','address':'1117 Budapest, Irinyi J. u. 1.','date':'2025-08-18','time':'13:30','price':'22 000 Ft','rating':4,'comment':'Gyors és pontos.'},
      ];
      await prefs.setString('provider_orders', json.encode(demo));
    }
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    await _seedIfEmpty();
    final raw = prefs.getString('provider_orders') ?? '[]';
    setState(()=> _items = (json.decode(raw) as List).cast<Map<String, dynamic>>());
  }
  Widget _stars(int rating) => Row(children: List.generate(5,(i)=> Icon(i<rating? Icons.star: Icons.star_border, color: Colors.amber, size: 18)));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Összes rendelés')),
      body: _items.isEmpty ? const Center(child: Text('Még nincs rendelés.'))
        : ListView.separated(padding: const EdgeInsets.all(12), itemCount: _items.length,
            separatorBuilder: (_, __)=> const SizedBox(height:8),
            itemBuilder: (_, i){
              final it=_items[i];
              return Card(child: ListTile(
                title: Text(it['service'] ?? ''),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                  Text('${it['address'] ?? ''}'),
                  Text('${it['date'] ?? ''}  ${it['time'] ?? ''}'),
                  const SizedBox(height:6),
                  _stars((it['rating'] ?? 0) as int),
                  if ((it['comment'] ?? '').toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top:4), child: Text('„${it['comment']}”')),
                ]),
                isThreeLine: true,
                trailing: Text(it['price'] ?? ''),
              ));
            }),
    );
  }
}
