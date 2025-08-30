import "package:flutter/material.dart";

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _serviceOptions = const [
    "Általános takarítás",
    "Nagytakarítás",
    "Felújítás utáni takarítás",
    "Karbantartás",
    "Vízszerelés",
    "Gázszerelés",
    "Légkondicionáló szerelés",
    "Bútorösszeszerelés",
    "Villanyszerelés",
  ];

  String? _service;
  final _addressCtrl = TextEditingController(); // Google Maps autocomplete helye
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => _time = t);
  }

  void _search() {
    if (_service == null || _addressCtrl.text.trim().isEmpty || _date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Válassz szolgáltatást, címet, dátumot és időt.")),
      );
      return;
    }

    // Itt normál esetben: Google Places → kerület kinyerés az address komponensekből.
    // Most csak továbbnavigálunk a találatokhoz (demó lista).
    Navigator.pushNamed(context, "/offers", arguments: {
      "service": _service,
      "address": _addressCtrl.text.trim(),
      "date": _date,
      "time": _time,
    });
  }

  @override
  Widget build(BuildContext context) {
    String fmtDate(DateTime? d) =>
        d == null ? "Válassz dátumot" : "${d.year}.${d.month.toString().padLeft(2,"0")}.${d.day.toString().padLeft(2,"0")}.";

    String fmtTime(TimeOfDay? t) =>
        t == null ? "Válassz időt" : "${t.hour.toString().padLeft(2,"0")}:${t.minute.toString().padLeft(2,"0")}";

    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltató keresése")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _serviceOptions.map((s) {
                final sel = _service == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: sel,
                  onSelected: (_) => setState(() => _service = s),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: "Cím (Google Maps)",
                hintText: "pl. Budapest, Lázár u. 1.",
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text(fmtDate(_date), textAlign: TextAlign.left),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTime,
                    child: Text(fmtTime(_time), textAlign: TextAlign.left),
                  ),
                ),
              ],
            ),
            const Spacer(),
            FilledButton(onPressed: _search, child: const Text("Keresés")),
          ],
        ),
      ),
    );
  }
}
