// lib/screens/customer_new_order_screen.dart
import "package:flutter/material.dart";

class CustomerNewOrderScreen extends StatefulWidget {
  const CustomerNewOrderScreen({super.key});

  @override
  State<CustomerNewOrderScreen> createState() => _CustomerNewOrderScreenState();
}

class _CustomerNewOrderScreenState extends State<CustomerNewOrderScreen> {
  final _services = const [
    "Általános takarítás",
    "Nagytakarítás",
    "Villanyszerelés",
    "Vízszerelés",
    "Bútorösszeszerelés",
    "Festés",
    "Kertgondozás",
  ];
  final _districts = const [
    "1. kerület","2. kerület","3. kerület","4. kerület","5. kerület","6. kerület","7. kerület","8. kerület","9. kerület","10. kerület",
    "11. kerület","12. kerület","13. kerület","14. kerület","15. kerület","16. kerület","17. kerület","18. kerület","19. kerület","20. kerület",
    "21. kerület","22. kerület","23. kerület",
  ];

  String? _service;
  String? _district;
  final _streetCtrl = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void dispose() {
    _streetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => _time = t);
  }

  void _search() {
    if (_service == null || _district == null || _streetCtrl.text.trim().isEmpty || _date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tölts ki minden mezőt!")));
      return;
    }
    Navigator.pushNamed(context, "/customer/search");
  }

  @override
  Widget build(BuildContext context) {
    String _dateLabel() {
      if (_date == null) return "Dátum";
      String two(int n) => n.toString().padLeft(2, "0");
      return "${_date!.year}.${two(_date!.month)}.${two(_date!.day)}.";
    }

    String _timeLabel() {
      if (_time == null) return "Idő";
      String two(int n) => n.toString().padLeft(2, "0");
      return "${two(_time!.hour)}:${two(_time!.minute)}";
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Új rendelés leadása")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Szolgáltatás
            DropdownButtonFormField<String>(
              value: _service,
              decoration: const InputDecoration(labelText: "Szolgáltatás"),
              items: _services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _service = v),
            ),
            const SizedBox(height: 12),

            // Kerület
            DropdownButtonFormField<String>(
              value: _district,
              decoration: const InputDecoration(labelText: "Kerület"),
              items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _district = v),
            ),
            const SizedBox(height: 12),

            // Utca
            TextField(
              controller: _streetCtrl,
              decoration: const InputDecoration(labelText: "Utca"),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),

            // Cím-validációs „térkép” placeholder (vizuális)
            Container(
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, size: 32, color: Colors.black54),
                  const SizedBox(height: 8),
                  if (_district != null && _streetCtrl.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.place, size: 16),
                          const SizedBox(width: 6),
                          Text("$_district, ${_streetCtrl.text}  •  cím validálva (demó)"),
                        ],
                      ),
                    )
                  else
                    const Text("Cím megadása után itt jelenik meg az ellenőrzés (demó)."),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Dátum + Idő
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Align(alignment: Alignment.centerLeft, child: Text(_dateLabel())),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTime,
                    child: Align(alignment: Alignment.centerLeft, child: Text(_timeLabel())),
                  ),
                ),
              ],
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _search, child: const Text("Keresés")),
            ),
          ],
        ),
      ),
    );
  }
}
