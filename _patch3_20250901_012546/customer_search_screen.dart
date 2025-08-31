import 'package:flutter/material.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});
  @override State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}
class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  String? _service; String? _address; DateTime? _date; TimeOfDay? _time;
  final _services = const [
    {'name':'Általános takarítás','icon': Icons.cleaning_services},
    {'name':'Nagytakarítás','icon': Icons.soap},
    {'name':'Felújítás utáni takarítás','icon': Icons.construction},
    {'name':'Karbantartás','icon': Icons.build},
    {'name':'Vízszerelés','icon': Icons.water_damage},
    {'name':'Villanyszerelés','icon': Icons.electric_bolt},
  ];
  Future<void> _pickAddress() async { final res = await Navigator.pushNamed(context, '/map_picker'); if (res is String && res.isNotEmpty) setState(()=> _address = res); }
  Future<void> _pickDate() async { final now=DateTime.now(); final d=await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: DateTime(now.year+1)); if(d!=null) setState(()=> _date=d); }
  Future<void> _pickTime() async { final t=await showTimePicker(context: context, initialTime: const TimeOfDay(hour:9, minute:0)); if(t!=null) setState(()=> _time=t); }
  void _search(){
    if (_service==null || _address==null || _date==null || _time==null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Töltsd ki a szolgáltatás, cím, dátum és idő mezőket.'))); return; }
    Navigator.pushNamed(context, '/offers', arguments: {'service':_service, 'address':_address, 'date':_date, 'time':_time});
  }
  @override
  Widget build(BuildContext context) {
    String dFmt(DateTime? d)=> d==null? 'Válassz dátumot' : '${d.year}.${d.month.toString().padLeft(2,'0')}.${d.day.toString().padLeft(2,'0')}.';
    String tFmt(TimeOfDay? t)=> t==null? 'Válassz időt' : '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltató keresése')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Szolgáltatás'), const SizedBox(height:6),
          Wrap(spacing:8, runSpacing:8, children: _services.map((o){
            final sel=_service==o['name']; return ChoiceChip(
              label: Row(mainAxisSize: MainAxisSize.min, children:[ Icon(o['icon'] as IconData, size:18), const SizedBox(width:6), Text(o['name'] as String), ]),
              selected: sel, onSelected: (_)=> setState(()=> _service = o['name'] as String),
            );
          }).toList()),
          const SizedBox(height:16),
          ListTile(onTap:_pickAddress, leading: const Icon(Icons.map), title: Text(_address ?? 'Cím kiválasztása (Google Maps)'),
            trailing: const Icon(Icons.chevron_right),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0x22000000)))),
          const SizedBox(height:12),
          Row(children:[
            Expanded(child: OutlinedButton(onPressed:_pickDate, child: Align(alignment: Alignment.centerLeft, child: Text(dFmt(_date))))),
            const SizedBox(width:8),
            Expanded(child: OutlinedButton(onPressed:_pickTime, child: Align(alignment: Alignment.centerLeft, child: Text(tFmt(_time))))),
          ]),
          const Spacer(),
          SizedBox(width: double.infinity, child: FilledButton(onPressed:_search, child: const Text('Keresés'))),
        ]),
      ),
    );
  }
}

