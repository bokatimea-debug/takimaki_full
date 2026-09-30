import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "dart:convert";


const _serviceOptions = [
  "Apartmantakarítás",
  "Mosodai szolgáltatás",
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
  final Set<DateTime> _dates = {};
  final Map<DateTime, TimeOfDay> _dateFrom = {};
  final Map<DateTime, TimeOfDay> _dateTo = {};
  final List<Map<String, dynamic>> _priceRules = [];
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
      final dts = (args["dates"] as List?)?.whereType<String>() ?? <String>[];
      _dates.addAll(dts.map(DateTime.tryParse).whereType<DateTime>());
      final hours = args["date_hours"];
      final rules = args["price_rules"];
      if (rules is List) {
        _priceRules.addAll(
          rules.whereType<Map>().map((rule) => Map<String, dynamic>.from(rule)),
        );
      }
      if (hours is Map) {
        for (final date in _dates) {
          final value = hours[_dateKey(date)];
          if (value is Map) {
            _dateFrom[date] = _parseTime(value["from"]?.toString()) ??
                const TimeOfDay(hour: 9, minute: 0);
            _dateTo[date] = _parseTime(value["to"]?.toString()) ??
                const TimeOfDay(hour: 18, minute: 0);
          }
        }
      }
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

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(":");
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _timeValue(TimeOfDay value) =>
      "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";

  Future<void> _pickDateHours(DateTime date) async {
    final from = await showTimePicker(
      context: context,
      initialTime: _dateFrom[date] ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: "Kezdés időpontja",
    );
    if (from == null || !mounted) return;
    final to = await showTimePicker(
      context: context,
      initialTime: _dateTo[date] ?? const TimeOfDay(hour: 18, minute: 0),
      helpText: "Befejezés időpontja",
    );
    if (to == null) return;
    if (to.hour * 60 + to.minute <= from.hour * 60 + from.minute) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("A befejezésnek később kell lennie a kezdésnél.")),
      );
      return;
    }
    setState(() {
      _dateFrom[date] = from;
      _dateTo[date] = to;
    });
  }

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
        _dateFrom.removeWhere((date, _) => !_dates.contains(date));
        _dateTo.removeWhere((date, _) => !_dates.contains(date));
        for (final date in _dates) {
          _dateFrom.putIfAbsent(date, () => const TimeOfDay(hour: 9, minute: 0));
          _dateTo.putIfAbsent(date, () => const TimeOfDay(hour: 18, minute: 0));
        }
      });
    }
  }

  Future<void> _addPriceRule() async {
    final isApartment = _service == "Apartmantakarítás";
    final isLaundry = _service == "Mosodai szolgáltatás";
    if (!isApartment && !isLaundry) return;
    final fromCtrl = TextEditingController();
    final toCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String laundryType = "Mosás és hajtogatás";
    String laundryUnit = "Ft/kg";
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isApartment ? "Új m² ársáv" : "Új mosodai ár"),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (isApartment)
                Row(children: [
                  Expanded(child: TextField(controller: fromCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Minimum m²"))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: toCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Maximum m²"))),
                ])
              else ...[
                DropdownButtonFormField<String>(
                  value: laundryType,
                  decoration: const InputDecoration(labelText: "Mosodai szolgáltatás"),
                  items: const [
                    DropdownMenuItem(value: "Mosás és hajtogatás", child: Text("Mosás és hajtogatás")),
                    DropdownMenuItem(value: "Mosás és vasalás", child: Text("Mosás és vasalás")),
                    DropdownMenuItem(value: "Csak vasalás", child: Text("Csak vasalás")),
                  ],
                  onChanged: (value) => setDialogState(() => laundryType = value!),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: laundryUnit,
                  decoration: const InputDecoration(labelText: "Elszámolás"),
                  items: const [
                    DropdownMenuItem(value: "Ft/kg", child: Text("Ft/kg")),
                    DropdownMenuItem(value: "Ft/garnitúra", child: Text("Ft/garnitúra")),
                    DropdownMenuItem(value: "Ft/darab", child: Text("Ft/darab")),
                  ],
                  onChanged: (value) => setDialogState(() => laundryUnit = value!),
                ),
              ],
              const SizedBox(height: 8),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Tájékoztató ár (Ft)")),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Mégse")),
            FilledButton(
              onPressed: () {
                final price = int.tryParse(priceCtrl.text.replaceAll(" ", ""));
                final from = int.tryParse(fromCtrl.text);
                final to = int.tryParse(toCtrl.text);
                if (price == null || price <= 0 ||
                    (isApartment && (from == null || to == null || from < 0 || to <= from))) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ellenőrizd a megadott adatokat.")));
                  return;
                }
                Navigator.pop(context, isApartment
                    ? {"type": "area", "from": from, "to": to, "price": price, "unit": "Ft"}
                    : {"type": "laundry", "label": laundryType, "price": price, "unit": laundryUnit});
              },
              child: const Text("Hozzáadás"),
            ),
          ],
        ),
      ),
    );
    fromCtrl.dispose();
    toCtrl.dispose();
    priceCtrl.dispose();
    if (result != null && mounted) setState(() => _priceRules.add(result));
  }

  Future<void> _save() async {
    if (_service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Válassz szolgáltatást.")),
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
    "districts": const <int>[],
    "dates": _dates
        .map((d) => DateTime(d.year, d.month, d.day).toIso8601String())
        .toList(),
    "date_hours": {
      for (final d in _dates)
        _dateKey(d): {
          "from": _timeValue(_dateFrom[d] ?? const TimeOfDay(hour: 9, minute: 0)),
          "to": _timeValue(_dateTo[d] ?? const TimeOfDay(hour: 18, minute: 0)),
        },
    },
    "price_rules": _priceRules,
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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        child: ListView(
        
          children: [
            const Text("Szolgáltatás"),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _serviceOptions.map((s) {
                final sel = _service == s;
                return ChoiceChip(
                  label: Text(
                    s,
                    style: TextStyle(
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  selected: sel,
                  onSelected: (_) => setState(() => _service = s),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            const Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(Icons.location_on_outlined),
                title: Text("Működési terület"),
                subtitle: Text("A Google Maps-alapú területválasztás a következő verzióban lesz elérhető."),
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
                    DropdownMenuItem(value: "Ft/m²", child: Text("Ft/m²")),
                    DropdownMenuItem(value: "Ft/kg", child: Text("Ft/kg")),
                    DropdownMenuItem(value: "Ft/garnitúra", child: Text("Ft/garnitúra")),
                    DropdownMenuItem(value: "Ft/darab", child: Text("Ft/darab")),
                  ],
                  onChanged: (v) => setState(() => _unit = v!),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Tájékoztató ár. A végleges díjról a felek az ajánlat és a chat során állapodnak meg.",
              style: TextStyle(fontSize: 12, color: Color(0xFF617577)),
            ),
            if (_service == "Apartmantakarítás" || _service == "Mosodai szolgáltatás") ...[
              const SizedBox(height: 12),
              Row(children: [
                const Expanded(child: Text("Részletes tájékoztató árlista", style: TextStyle(fontWeight: FontWeight.w700))),
                IconButton.filledTonal(onPressed: _addPriceRule, icon: const Icon(Icons.add)),
              ]),
              if (_priceRules.isEmpty)
                const Text("A + gombbal több m²-sávot vagy mosodai egységárat adhatsz hozzá."),
              ..._priceRules.asMap().entries.map((entry) {
                final rule = entry.value;
                final label = rule["type"] == "area"
                    ? "${rule["from"]}–${rule["to"]} m²"
                    : rule["label"].toString();
                return Card(
                  margin: const EdgeInsets.only(top: 6),
                  child: ListTile(
                    dense: true,
                    title: Text(label),
                    subtitle: Text("${_fmtTh(rule["price"] as int)} ${rule["unit"]}"),
                    trailing: IconButton(onPressed: () => setState(() => _priceRules.removeAt(entry.key)), icon: const Icon(Icons.delete_outline)),
                  ),
                );
              }),
            ],

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
              ...((_dates.toList()..sort((a, b) => a.compareTo(b))).map(
                (d) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    title: Text(_fmtDate(d)),
                    subtitle: Text(
                      "${_timeValue(_dateFrom[d] ?? const TimeOfDay(hour: 9, minute: 0))}–${_timeValue(_dateTo[d] ?? const TimeOfDay(hour: 18, minute: 0))}",
                    ),
                    trailing: const Icon(Icons.schedule),
                    onTap: () => _pickDateHours(d),
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: SizedBox(
          height: 52,
          child: FilledButton(onPressed: _save, child: const Text("Mentés")),
        ),
      ),
    );
  }
}
