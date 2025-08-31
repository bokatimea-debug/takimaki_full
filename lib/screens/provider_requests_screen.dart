import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({super.key});
  @override State<ProviderRequestsScreen> createState() => _S();
}
class _S extends State<ProviderRequestsScreen> {
  List<Map<String, dynamic>> _items = [];
  @override void initState(){ super.initState(); _load(); }
  Future<void> _seedIfEmpty() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('provider_requests');
    if (raw == null || raw.isEmpty || raw == '[]') {
      final demo = [
        { 'id':'rq1','service':'Általános takarítás','address':'1138 Budapest, Váci út 99.','date':'2025-09-02','time':'10:00','status':'new','suggested_price':'12000' },
        { 'id':'rq2','service':'Vízszerelés','address':'1053 Budapest, Kossuth Lajos u. 1.','date':'2025-09-03','time':'14:30','status':'new','suggested_price':'18000' },
      ];
      await prefs.setString('provider_requests', json.encode(demo));
    }
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    await _seedIfEmpty();
    final raw = prefs.getString('provider_requests') ?? '[]';
    setState(()=> _items = (json.decode(raw) as List).cast<Map<String, dynamic>>());
  }
  Future<void> _decline(String id) async {
    final prefs = await SharedPreferences.getInstance();
    _items.removeWhere((e)=> e['id'] == id);
    await prefs.setString('provider_requests', json.encode(_items));
    setState((){});
  }
  Future<void> _open(Map<String, dynamic> it) async {
    final ok = await Navigator.pushNamed(context, '/provider/offer_reply', arguments: it) as bool?;
    if (ok == true) await _load(); else await _load();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beérkezett ajánlatkérések')),
      body: _items.isEmpty ? const Center(child: Text('Jelenleg nincs beérkezett kérés.'))
        : ListView.separated(padding: const EdgeInsets.all(12), itemCount: _items.length,
            separatorBuilder: (_, __)=> const SizedBox(height:8),
            itemBuilder: (_, i){
              final it=_items[i]; final status=(it['status']??'new') as String;
              return Card(
                child: ListTile(
                  title: Text(it['service'] ?? ''),
                  subtitle: Text('${it['address'] ?? ''}\n${it['date'] ?? ''}  ${it['time'] ?? ''}'),
                  isThreeLine: true,
                  onTap: () async { final res = await Navigator.pushNamed(context, '/provider/offer_reply', arguments: {'requestId': r['id']}); if (res is Map && res['ok']==true) { if(mounted) setState((){}); } },
                  trailing: Wrap(spacing:4, children:[
                    if (status=='new' || status=='offered')
                      IconButton(tooltip:'Elutasítás', onPressed: ()=> _decline(it['id']), icon: const Icon(Icons.close)),
                  ]),
                ),
              );
            }),
    );
  }
}


