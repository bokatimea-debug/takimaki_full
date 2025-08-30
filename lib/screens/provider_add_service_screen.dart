// lib/screens/provider_add_service_screen.dart
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../services/service_store.dart";

/// Ezres tagolás az ár mezőben (csak számokat enged, 12 000 formátum).
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r"[^0-9]"), "");
    if (digits.isEmpty) {
      return const TextEditingValue(text: "");
    }
    final sb = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final idxFromEnd = digits.length - i;
      sb.write(digits[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) sb.write(" ");
    }
    final t = sb.toString();
    return TextEditingValue(text: t, selection: TextSelection.collapsed(offset: t.length));
  }
}

class ProviderAddServiceScreen extends StatefulWidget {
  const ProviderAddServiceScreen({super.key});

  @override
  State<ProviderAddServiceScreen> createState() => _ProviderAddServiceScreenState();
}

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  final store = ServiceStore.instance;

  // Előre definiált szolgáltatások listája
  final List<String> _serviceOptions = const [
    "Általános takarítás",
    "Nagytakarítás",
    "Villanyszerelés",
    "Vízszerelés",
    "Bútorösszeszerelés",
    "Festés",
    "Kertgondozás",
  ];

  String? _selectedService;

  /// Kiválasztott kerületek (I..XXIII)
  final Set<String> _districts = {};

  final priceCtrl = TextEditingController();
  PriceUnit _unit = PriceUnit.ftPerHour;

  /// Elérhetőségi idősávok – átfedés engedett
  final List<ServiceSlot> _slots = [];

  @override
  void dispose() {
    priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDistricts() async {
    final all = [
      "I","II","III","IV","V","VI","VII","VIII","IX","X",
      "XI","XII","XIII","XIV","XV","XVI","XVII","XVIII","XIX","XX",
      "XXI","XXII","XXIII"
    ];
    final temp = Set<String>.from(_districts);
    final res = await showDialog<Set<String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Budapest, kerületek"),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FilterChip(
                label: const Text("Mind"),
                selected: temp.length == all.length,
                onSelected: (v) {
                  if (v) {
                    temp
                      ..clear()
                      ..addAll(all);
                  } else {
                    temp.clear();
                  }
                  setState(() {});
                },
              ),
              ...all.map((d) => FilterChip(
                    label: Text(d),
                    selected: temp.contains(d),
                    onSelected: (v) => v ? temp.add(d) : temp.remove(d),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Mégse")),
          FilledButton(onPressed: () => Navigator.pop(context, temp), child: const Text("Mentés")),
        ],
      ),
    );
    if (res != null) {
      setState(() {
        _districts
          ..clear()
          ..addAll(res);
      });
    }
  }

  Future<void> _addSlot() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) return;

    final from = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (from == null) return;

    final to = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 16, minute: 0));
    if (to == null) return;

    setState(() {
      _slots.add(ServiceSlot(date: DateTime(date.year, date.month, date.day), from: from, to: to));
    });
  }

  void _removeSlot(int index) => setState(() => _slots.removeAt(index));

  void _save() {
    final priceDigits = priceCtrl.text.replaceAll(" ", "");
    if (_selectedService == null || _districts.isEmpty || priceDigits.isEmpty || _slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tölts ki minden mezőt: szolgáltatás, kerület(ek), ár és idősáv.")),
      );
      return;
    }
    final price = int.tryParse(priceDigits) ?? 0;

    final service = ProviderService(
      name: _selectedService!,
      districts: (_districts.toList()..sort()),
      price: price,
      unit: _unit,
      slots: List<ServiceSlot>.from(_slots),
    );

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int) {
      store.update(arg, service);
    } else {
      store.add(service);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Szerkesztés esetén előtöltés
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int) {
      final existing = store.services[arg];
      _selectedService ??= existing.name;
      if (_districts.isEmpty) _districts.addAll(existing.districts);
      if (priceCtrl.text.isEmpty) {
        final s = existing.price.toString();
        final sb = StringBuffer();
        for (int i = 0; i < s.length; i++) {
          final idxFromEnd = s.length - i;
          sb.write(s[i]);
          if (idxFromEnd > 1 && idxFromEnd % 3 == 1) sb.write(" ");
        }
        priceCtrl.text = sb.toString();
      }
      _unit = existing.unit;
      if (_slots.isEmpty) _slots.addAll(existing.slots);
    }

    String districtsLabel() =>
        _districts.isEmpty ? "Nincs kiválasztva" : (_districts.toList()..sort()).join(", ");

    String two(int n) => n.toString().padLeft(2, "0");

    return Scaffold(
      appBar: AppBar(title: const Text("Új szolgáltatás")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) Szolgáltatás választó (chips)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _serviceOptions.map((opt) {
                final sel = _selectedService == opt;
                return ChoiceChip(
                  label: Text(opt),
                  selected: sel,
                  onSelected: (_) => setState(() => _selectedService = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // 2) Kerületek
            Row(
              children: [
                const Expanded(child: Text("Budapest, kerületek")),
                TextButton(onPressed: _pickDistricts, child: const Text("Kiválasztás")),
              ],
            ),
            Text(
              districtsLabel(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // 3) Ár + egység
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsFormatter()],
                    decoration: const InputDecoration(labelText: "Ár", hintText: "pl. 12 000"),
                  ),
                ),
                const SizedBox(width: 8),
                ToggleButtons(
                  isSelected: [_unit == PriceUnit.ftPerHour, _unit == PriceUnit.ftPerSqm],
                  onPressed: (i) => setState(() => _unit = i == 0 ? PriceUnit.ftPerHour : PriceUnit.ftPerSqm),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("Ft/óra")),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("Ft/nm")),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 4) Idősávok
            Row(
              children: [
                const Expanded(child: Text("Elérhetőség (nap + óra/perc)")),
                TextButton(onPressed: _addSlot, child: const Text("Hozzáadás")),
              ],
            ),
            if (_slots.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(_slots.length, (i) {
                  final s = _slots[i];
                  final d = "${s.date.year}.${two(s.date.month)}.${two(s.date.day)}.";
                  final f = "${two(s.from.hour)}:${two(s.from.minute)}";
                  final t = "${two(s.to.hour)}:${two(s.to.minute)}";
                  return InputChip(label: Text("$d • $f–$t"), onDeleted: () => _removeSlot(i));
                }),
              )
            else
              const Text("Nincs idősáv megadva"),

            const Spacer(),

            // 5) Mentés
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: const Text("Mentés")),
            ),
          ],
        ),
      ),
    );
  }
}
