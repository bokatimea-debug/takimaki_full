import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "dart:convert";

const _serviceOptions = [
  "Általános takarítás",
  "Nagytakarítás",
  "Felújítás utáni takarítás",
  "Karbantartás",
  "Vízszerelés",
  "Villanyszerelés",
];

class ProviderAddServiceScreen extends StatefulWidget {
  const ProviderAddServiceScreen({super.key});
  @override
  State<ProviderAddServiceScreen> createState() => _ProviderAddServiceScreenState();
}

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  String? _service;
  final _priceCtrl = TextEditingController();
  String _unit = "Ft/óra";
  final Set<int> _districts = {};
  final Set<DateTime> _dates = {};

  @override
  void initState() {
    super.initState();
    final args = ModalRoute.of(context)?.settings.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_){
      if (args is Map<String, dynamic>) {
        setState(() {
          _service = args["name"] as String?;
          _priceCtrl.text = (args["price_raw"]?.toString() ?? "");
          _unit = args["unit"] ?? _unit;
          final ds = (args["districts"] as List?)?.cast<int>() ?? <int>[];
          _districts.addAll(ds);
          final dts = (args["dates"] as List?)?.cast<String>() ?? <String>[];
          _dates.addAll(dts.map((e)=> DateTime.tryParse(e)!).whereType<DateTime>());
        });
      }
    });
  }

  String _fmtTh(int v) {
    final s = v.toString();
    final buf = <String>[];
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i - 1;
      buf.insert(0, s[idx]);
      if (i % 3 == 2 && idx != 0) buf.insert(0, " ");
    }
    return buf.join();
  }

  String _fmtDate(DateTime d) =>
      "${d.year}.${d.month.toString().padLeft(2,'0')}.${d.day.toString().padLeft(2,'0')}.";

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (d != null) {
      setState(() {
        final day = DateTime(d.year, d.month, d.day);
        if (_dates.contains(day)) _dates.remove(day); else _dates.add(day);
      });
    }
  }

  Future<void> _save() async {
    if (_service == null || _districts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Válassz szolgáltatást és kerületeket."))
      );
      return;
    }
    final priceRaw = int.tryParse(_priceCtrl.text.replaceAll(" ", ""));
    if (priceRaw == null || priceRaw <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Adj meg érvényes árat."))
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("provider_services") ?? "[]";
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final idx = list.indexWhere((e) => e["id"] == args["id"]);
      final item = _buildItem(args["id"] ?? DateTime.now().millisecondsSinceEpoch.toString());
      if (idx >= 0) list[idx] = item; else list.add(item);
    } else {
      list.add(_buildItem(DateTime.now().millisecondsSinceEpoch.toString()));
    }

    await prefs.setString("provider_services", json.encode(list));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Szolgáltatás mentve"))
    );
    Navigator.pop(context, true);
  }

  Map<String, dynamic> _buildItem(String id) => {
    "id": id,
    "name": _service,
    "price_raw": int.parse(_priceCtrl.text.replaceAll(" ", "")),
    "price_fmt": _fmtTh(int.parse(_priceCtrl.text.replaceAll(" ", ""))),
    "unit": _unit,
    "districts": _districts.toList()..sort(),
    "dates": _dates.map((d)=> DateTime(d.year, d.month, d.day).toIso8601String()).toList(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Új szolgáltatás")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Szolgáltatás"),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _serviceOptions.map((s){
                final sel = _service == s;
                return ChoiceChip(
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (sel) const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.check, size: 16),
                    ),
                    Text(s, style: TextStyle(fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                  ]),
                  selected: sel,
                  onSelected: (_)=> setState(()=> _service = s),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            const Text("Kerületek (Budapest I–XXIII)"),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: List.generate(23, (i){
                final n = i+1;
                final sel = _districts.contains(n);
                final label = switch (n) {
                  1 => "I", 2 => "II", 3 => "III",
                  20 => "XX", 21 => "XXI", 22 => "XXII", 23 => "XXIII",
                  _ => "$n"
                };
                return FilterChip(
                  selected: sel,
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (sel) const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.check, size: 16),
                    ),
                    Text(label, style: TextStyle(fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                  ]),
                  onSelected: (_){
                    setState(() {
                      if (sel) _districts.remove(n); else _districts.add(n);
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Ár (Ft)"),
                    onChanged: (v){
                      final num = int.tryParse(v.replaceAll(" ", ""));
                      if (num != null) {
                        final txt = _fmtTh(num);
                        _priceCtrl.value = TextEditingValue(
                          text: txt,
                          selection: TextSelection.collapsed(offset: txt.length),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _unit,
                  items: const [
                    DropdownMenuItem(value: "Ft/óra", child: Text("Ft/óra")),
                    DropdownMenuItem(value: "Ft/nm", child: Text("Ft/nm")),
                  ],
                  onChanged: (v)=> setState(()=> _unit = v!),
                ),
              ],
            ),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event),
              label: Text(_dates.isEmpty ? "Napok kiválasztása (több is lehet)" : "Kiválasztott napok: ${_dates.length}"),
            ),

            if (_dates.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: ((_dates.toList()..sort((a,b)=> a.compareTo(b)))
                  .map<Widget>((d)=> Chip(label: Text(_fmtDate(d))))
                  .toList()),
              ),
            ],

            const Spacer(),
            FilledButton(onPressed: _save, child: const Text("Mentés")),
          ],
        ),
      ),
    );
  }
}
