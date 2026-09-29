import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "dart:convert";

import "../widgets/district_picker.dart";

const _serviceOptions = [
  "Apartmantakarítás",
  "Általános takarítás",
  "Nagytakarítás",
  "Vízszerelés",
  "Gázszerelés",
  "Karbantartás",
  "Klíma",
  "Bútorszerelés",
];

class ProviderAddServiceScreen extends StatefulWidget {
  const ProviderAddServiceScreen({super.key});
  @override
  State<ProviderAddServiceScreen> createState() =>
      _ProviderAddServiceScreenState();
}

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  String? _service;
  final _priceCtrl = TextEditingController();
  String _unit = "Ft/óra";
  final Set<int> _districts = {};
  final Set<DateTime> _dates = {};
  bool _argumentsLoaded = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentsLoaded) return;
    _argumentsLoaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _isEditing = true;
      _service = args["name"] as String?;
      _priceCtrl.text = (args["price_raw"]?.toString() ?? "");
      _unit = args["unit"] ?? _unit;
      final ds = (args["districts"] as List?)?.whereType<int>() ?? <int>[];
      _districts.addAll(ds);
      final dts = (args["dates"] as List?)?.whereType<String>() ?? <String>[];
      _dates.addAll(dts.map(DateTime.tryParse).whereType<DateTime>());
    }
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
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
      "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.";

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = Set<DateTime>.from(_dates);
    final result = await showModalBottomSheet<Set<DateTime>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final selected = Set<DateTime>.from(initial);
        return StatefulBuilder(
          builder: (context, setModalState) => SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.72,
              child: Column(
                children: [
                  const Text(
                    "Egyedi napok",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text("Kiválasztva: ${selected.length}/10"),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.45,
                          ),
                      itemCount: 90,
                      itemBuilder: (context, index) {
                        final date = DateTime(
                          now.year,
                          now.month,
                          now.day + index,
                        );
                        final isSelected = selected.contains(date);
                        return FilterChip(
                          selected: isSelected,
                          label: Text(
                            "${date.month}.${date.day}.",
                            textAlign: TextAlign.center,
                          ),
                          onSelected: (value) {
                            if (value && selected.length >= 10) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Legfeljebb 10 egyedi nap választható.",
                                  ),
                                ),
                              );
                              return;
                            }
                            setModalState(() {
                              value
                                  ? selected.add(date)
                                  : selected.remove(date);
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, selected),
                        child: const Text("Kész"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _dates
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _pickDistricts() async {
    final result = await pickDistricts(context, _districts.toList());
    if (result != null) {
      setState(() {
        _districts
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _save() async {
    if (_service == null || _districts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Válassz szolgáltatást és kerületeket.")),
      );
      return;
    }
    final priceRaw = int.tryParse(_priceCtrl.text.replaceAll(" ", ""));
    if (priceRaw == null || priceRaw <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Adj meg érvényes árat.")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("provider_services") ?? "[]";
    final list = (json.decode(raw) as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    final args = ModalRoute.of(context)?.settings.arguments;
    final editingId = args is Map<String, dynamic> ? args["id"] : null;
    final duplicate = list.any(
      (item) => item["name"] == _service && item["id"] != editingId,
    );
    if (duplicate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ez a szolgáltatás már szerepel a listában."),
        ),
      );
      return;
    }
    if (args is Map<String, dynamic>) {
      final idx = list.indexWhere((e) => e["id"] == args["id"]);
      final item = _buildItem(
        args["id"] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      );
      if (idx >= 0)
        list[idx] = item;
      else
        list.add(item);
    } else {
      list.add(_buildItem(DateTime.now().millisecondsSinceEpoch.toString()));
    }

    await prefs.setString("provider_services", json.encode(list));

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Szolgáltatás mentve")));
    Navigator.pop(context, true);
  }

  Map<String, dynamic> _buildItem(String id) => {
    "id": id,
    "name": _service,
    "price_raw": int.parse(_priceCtrl.text.replaceAll(" ", "")),
    "price_fmt": _fmtTh(int.parse(_priceCtrl.text.replaceAll(" ", ""))),
    "unit": _unit,
    "districts": _districts.toList()..sort(),
    "dates": _dates
        .map((d) => DateTime(d.year, d.month, d.day).toIso8601String())
        .toList(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? "Szolgáltatás szerkesztése" : "Új szolgáltatás",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Szolgáltatás"),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _serviceOptions.map((s) {
                final sel = _service == s;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sel)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.check, size: 16),
                        ),
                      Text(
                        s,
                        style: TextStyle(
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  selected: sel,
                  onSelected: (_) => setState(() => _service = s),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            const Text("Működési terület"),
            const SizedBox(height: 6),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _districts.length == 23,
              title: const Text("Egész Budapest"),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (selected) {
                setState(() {
                  _districts.clear();
                  if (selected == true) {
                    _districts.addAll(List.generate(23, (index) => index + 1));
                  }
                });
              },
            ),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                onTap: _pickDistricts,
                leading: const Icon(Icons.location_city_outlined),
                title: const Text("Budapest"),
                subtitle: Text(summarizeDistricts(_districts.toList())),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Ár (Ft)"),
                    onChanged: (v) {
                      final num = int.tryParse(v.replaceAll(" ", ""));
                      if (num != null) {
                        final txt = _fmtTh(num);
                        _priceCtrl.value = TextEditingValue(
                          text: txt,
                          selection: TextSelection.collapsed(
                            offset: txt.length,
                          ),
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
                  onChanged: (v) => setState(() => _unit = v!),
                ),
              ],
            ),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event),
              label: Text(
                _dates.isEmpty
                    ? "Egyedi napok kiválasztása"
                    : "Kiválasztott napok: ${_dates.length}/10",
              ),
            ),

            if (_dates.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ((_dates.toList()..sort((a, b) => a.compareTo(b)))
                    .map<Widget>((d) => Chip(label: Text(_fmtDate(d))))
                    .toList()),
              ),
            ],

            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text("Mentés")),
          ],
        ),
      ),
    );
  }
}
