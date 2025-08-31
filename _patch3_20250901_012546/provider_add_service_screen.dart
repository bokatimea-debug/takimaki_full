import '../repositories/provider_services_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const _serviceOptions = [
  'Általános takarítás','Nagytakarítás','Felújítás utáni takarítás','Karbantartás','Vízszerelés','Villanyszerelés',
];

class ProviderAddServiceScreen extends StatefulWidget {
  const ProviderAddServiceScreen({super.key});
  @override State<ProviderAddServiceScreen> createState() => _ProviderAddServiceScreenState();
}
class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  String? _service; final _priceCtrl = TextEditingController(); String _unit = 'Ft/óra';
  final Set<int> _districts = {}; final Set<DateTime> _dates = {};
  @override void initState(){ super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        setState(() {
          _service = args['name'] as String?;
          _priceCtrl.text = (args['price_raw']?.toString() ?? '');
          _unit = args['unit'] ?? _unit;
          _districts.addAll(((args['districts'] as List?)?.cast<int>() ?? <int>[]));
          final dts = (args['dates'] as List?)?.cast<String>() ?? <String>[];
          _dates.addAll(dts.map((e)=> DateTime.tryParse(e)!).whereType<DateTime>());
        });
      }
    });
  }
  String _fmtTh(int v){ final s=v.toString(); final b=<String>[]; for(int i=0;i<s.length;i++){final idx=s.length-i-1; b.insert(0,s[idx]); if(i%3==2 && idx!=0)b.insert(0,' ');} return b.join(); }
  String _fmtDate(DateTime d)=> '${d.year}.${d.month.toString().padLeft(2,'0')}.${d.day.toString().padLeft(2,'0')}.';
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: DateTime(now.year+1));
    if (d!=null) {
      final day = DateTime(d.year,d.month,d.day);
      setState(()=> _dates.contains(day) ? _dates.remove(day) : _dates.add(day));
    }
  }
  Future<void> _save() async {
    if (_service==null || _districts.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Válassz szolgáltatást és kerületeket.'))); return; }
    final priceRaw = int.tryParse(_priceCtrl.text.replaceAll(' ','')); if (priceRaw==null || priceRaw<=0){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adj meg érvényes árat.'))); return; }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('provider_services') ?? '[]';
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    final args = ModalRoute.of(context)?.settings.arguments;
    Map<String,dynamic> item(String id)=> {
      'id': id, 'name': _service, 'price_raw': priceRaw, 'price_fmt': _fmtTh(priceRaw), 'unit': _unit,
      'districts': _districts.toList()..sort(), 'dates': _dates.map((d)=> DateTime(d.year,d.month,d.day).toIso8601String()).toList(),
    };
    if (args is Map<String, dynamic>) {
      final idx = list.indexWhere((e)=> e['id']==args['id']);
      if (idx>=0) list[idx]=item(args['id']); else list.add(item(args['id']?? DateTime.now().millisecondsSinceEpoch.toString()));
    } else {
      list.add(item(DateTime.now().millisecondsSinceEpoch.toString()));
    }
    await prefs.setString('provider_services', json.encode(list));
    if (!mounted) return; Navigator.pop(context,true);
  }
  String _roman(int n) => const ['','I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII','XIII','XIV','XV','XVI','XVII','XVIII','XIX','XX','XXI','XXII','XXIII'][n];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Új szolgáltatás')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Szolgáltatás'), const SizedBox(height:6),
          Wrap(spacing:8, runSpacing:8, children: _serviceOptions.map((s){ final sel=_service==s; return ChoiceChip(
            label: Row(mainAxisSize: MainAxisSize.min, children:[ if(sel) const Padding(padding: EdgeInsets.only(right:6), child: Icon(Icons.check, size:16)), Text(s, style: TextStyle(fontWeight: sel? FontWeight.w600: FontWeight.w400)), ]),
            selected: sel, onSelected: (_)=> setState(()=> _service=s),
          ); }).toList()),
          const SizedBox(height:12),
          const Text('Kerületek (Budapest I–XXIII)'), const SizedBox(height:6),
          Wrap(spacing:6, runSpacing:6, children: List.generate(23,(i){ final n=i+1; final sel=_districts.contains(n);
            String r=_roman(n);
            return FilterChip(selected: sel, label: Row(mainAxisSize: MainAxisSize.min, children:[ if(sel) const Padding(padding: EdgeInsets.only(right:4), child: Icon(Icons.check, size:16)), Text(r, style: TextStyle(fontWeight: sel? FontWeight.w600: FontWeight.w400)) ]),
              onSelected: (_){ setState(()=> sel ? _districts.remove(n) : _districts.add(n)); });
          })),
          const SizedBox(height:12),
          Row(children:[
            Expanded(child: TextField(controller:_priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:'Ár (Ft)'),
              onChanged:(v){ final num=int.tryParse(v.replaceAll(' ','')); if(num!=null){ final t=_fmtTh(num); _priceCtrl.value=TextEditingValue(text:t, selection: TextSelection.collapsed(offset:t.length)); } },)),
            const SizedBox(width:8),
            DropdownButton<String>(value:_unit, items: const [
              DropdownMenuItem(value:'Ft/óra', child: Text('Ft/óra')),
              DropdownMenuItem(value:'Ft/nm',  child: Text('Ft/nm')),
            ], onChanged:(v)=> setState(()=> _unit=v!)),
          ]),
          const SizedBox(height:12),
          OutlinedButton.icon(onPressed:_pickDate, icon: const Icon(Icons.event),
            label: Text(_dates.isEmpty? 'Napok kiválasztása (több is lehet)' : 'Kiválasztott napok: ${_dates.length}')),
          if (_dates.isNotEmpty) ...[
            const SizedBox(height:8),
            Wrap(spacing:6, runSpacing:6, children: ((_dates.toList()..sort()).map<Widget>((d)=> Chip(label: Text(_fmtDate(d)))).toList())),
          ],
          const Spacer(),
          FilledButton(onPressed:_save, child: const Text('Mentés')),
        ]),
      ),
    );
  }
}

