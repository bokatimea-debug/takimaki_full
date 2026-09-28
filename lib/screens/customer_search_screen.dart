import "package:flutter/material.dart";

import "../services/local_marketplace_store.dart";
import "../utils/district_utils.dart";

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});
  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  String? _service;
  String? _address;
  DateTime? _date;
  TimeOfDay? _time;
  int? _district;
  bool _laundryAndIroning = false;
  final _noteController = TextEditingController();

  final _services = const [
    {"name":"Apartmantakarítás","icon": Icons.apartment},
    {"name":"Általános takarítás","icon": Icons.cleaning_services},
    {"name":"Nagytakarítás","icon": Icons.soap},
    {"name":"Vízszerelés","icon": Icons.water_damage},
    {"name":"Gázszerelés","icon": Icons.local_fire_department},
    {"name":"Karbantartás","icon": Icons.build},
    {"name":"Klíma","icon": Icons.ac_unit},
    {"name":"Bútorszerelés","icon": Icons.chair_alt},
  ];

  Future<void> _pickAddress() async {
    final res = await Navigator.pushNamed(context, "/map_picker");
    if (res is String && res.isNotEmpty) setState(()=> _address = res);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: DateTime(now.year+1));
    if (d!=null) setState(()=> _date=d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour:9, minute:0));
    if (t!=null) setState(()=> _time=t);
  }

  Future<void> _search() async {
    if (_service==null || _district == null || _address==null || _date==null || _time==null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Töltsd ki a szolgáltatás, cím, dátum és idő mezőket.")));
      return;
    }
    final dateTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    final requestId = await LocalMarketplaceStore.createRequest(
      service: _service!,
      district: romanFromDistrict(_district!),
      address: _address!,
      dateTime: dateTime,
      note: _noteController.text.trim(),
      laundryAndIroning:
          _service == "Apartmantakarítás" && _laundryAndIroning,
    );
    if (!mounted) return;
    Navigator.pushNamed(context, "/offers", arguments: {
      "request_id": requestId,
      "service": _service,
      "district": romanFromDistrict(_district!),
      "address": _address,
      "date": _date,
      "time": _time,
      "laundry_and_ironing":
          _service == "Apartmantakarítás" && _laundryAndIroning,
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dFmt(DateTime? d)=> d==null? "Válassz dátumot" : "${d.year}.${d.month.toString().padLeft(2,'0')}.${d.day.toString().padLeft(2,'0')}.";
    String tFmt(TimeOfDay? t)=> t==null? "Válassz időt" : "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";

    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltató keresése")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Szolgáltatás"),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _services.map((o){
                final sel = _service == o["name"];
                return ChoiceChip(
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(o["icon"] as IconData, size: 18),
                    const SizedBox(width: 6),
                    Text(o["name"] as String),
                  ]),
                  selected: sel,
                  onSelected: (_) => setState(() {
                    _service = o["name"] as String;
                    if (_service != "Apartmantakarítás") {
                      _laundryAndIroning = false;
                    }
                  }),
                );
              }).toList(),
            ),
            if (_service == "Apartmantakarítás") ...[
              const SizedBox(height: 10),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _laundryAndIroning,
                title: const Text("Mosással és vasalással"),
                subtitle: Text(
                  _laundryAndIroning
                      ? "A rendelés mosást és vasalást is tartalmaz."
                      : "A rendelés mosás és vasalás nélkül készül.",
                ),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) =>
                    setState(() => _laundryAndIroning = value ?? false),
              ),
            ],
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: _district,
              decoration: const InputDecoration(labelText: "Budapest kerület"),
              items: List.generate(
                23,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text("Budapest ${romanFromDistrict(index + 1)}. kerület"),
                ),
              ),
              onChanged: (value) => setState(() => _district = value),
            ),
            const SizedBox(height: 12),

            // CÍM (Google Maps külön képernyő)
            ListTile(
              onTap: _pickAddress,
              leading: const Icon(Icons.map),
              title: Text(_address ?? "Cím kiválasztása (Google Maps)"),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0x22000000))),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _pickDate, child: Align(alignment: Alignment.centerLeft, child: Text(dFmt(_date))))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(onPressed: _pickTime, child: Align(alignment: Alignment.centerLeft, child: Text(tFmt(_time))))),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Megjegyzés (opcionális)",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _search, child: const Text("Keresés"))),
          ],
        ),
      ),
    );
  }
}
