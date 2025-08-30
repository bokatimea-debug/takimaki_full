// lib/screens/customer_search_screen.dart
import "package:flutter/material.dart";
import "package:geocoding/geocoding.dart";
import "../utils/district_utils.dart";
import "map_picker_screen.dart";

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});
  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _options = const [
    {"name":"Általános takarítás","icon": Icons.cleaning_services},
    {"name":"Nagytakarítás","icon": Icons.local_laundry_service},
    {"name":"Felújítás utáni takarítás","icon": Icons.build},
    {"name":"Karbantartás","icon": Icons.handyman},
    {"name":"Vízszerelés","icon": Icons.water_damage},
    {"name":"Gázszerelés","icon": Icons.local_fire_department},
    {"name":"Légkondi szerelés","icon": Icons.ac_unit},
    {"name":"Bútorösszeszerelés","icon": Icons.chair_alt},
    {"name":"Villanyszerelés","icon": Icons.electric_bolt},
  ];

  String? _service;
  final _addressCtrl = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void dispose() { _addressCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: DateTime(now.year+1));
    if (d!=null) setState(()=> _date=d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9,minute: 0));
    if (t!=null) setState(()=> _time=t);
  }

  Future<void> _openMap() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_)=> const MapPickerScreen()));
    if (res is String && res.isNotEmpty) {
      setState(()=> _addressCtrl.text = res);
    }
  }

  Future<String?> _extractDistrictFromAddress(String address) async {
    try {
      final loc = await locationFromAddress(address, localeIdentifier: "hu_HU");
      if (loc.isEmpty) return null;
      final places = await placemarkFromCoordinates(loc.first.latitude, loc.first.longitude, localeIdentifier: "hu_HU");
      if (places.isEmpty) return null;
      final p = places.first;
      final postal = p.postalCode ?? "";
      return districtFromPostal(postal);
    } catch (_) { return null; }
  }

  Future<void> _search() async {
    if (_service==null || _addressCtrl.text.trim().isEmpty || _date==null || _time==null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Válassz szolgáltatást, címet, dátumot és időt."))); return;
    }
    final district = await _extractDistrictFromAddress(_addressCtrl.text.trim());
    Navigator.pushNamed(context, "/offers", arguments: {
      "service": _service,
      "address": _addressCtrl.text.trim(),
      "date": _date,
      "time": _time,
      "district": district, // háttérben szűréshez
    });
  }

  @override
  Widget build(BuildContext context) {
    String fd(DateTime? d)=> d==null? "Válassz dátumot" : "${d.year}.${d.month.toString().padLeft(2,'0')}.${d.day.toString().padLeft(2,'0')}.";
    String ft(TimeOfDay? t)=> t==null? "Válassz időt" : "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";

    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltató keresése")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _options.map((o){
                final sel = _service == o["name"];
                return FilterChip(
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(o["icon"] as IconData, size: 18),
                    const SizedBox(width: 6),
                    Text(o["name"] as String),
                  ]),
                  selected: sel,
                  onSelected: (_)=> setState(()=> _service = o["name"] as String),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              decoration: InputDecoration(
                labelText: "Cím (Google Maps)",
                suffixIcon: IconButton(icon: const Icon(Icons.map), onPressed: _openMap),
              ),
              onSubmitted: (_)=> _search(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _pickDate, child: Align(alignment: Alignment.centerLeft, child: Text(fd(_date))))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(onPressed: _pickTime, child: Align(alignment: Alignment.centerLeft, child: Text(ft(_time))))),
              ],
            ),
            const Spacer(),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _search, child: const Text("Keresés"))),
          ],
        ),
      ),
    );
  }
}
