import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../services/service_store.dart";

/// Ezres tagolás az árhoz.
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r"[^0-9]"), "");
    if (digits.isEmpty) {
      return const TextEditingValue(text: "");
    }
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final idxFromEnd = digits.length - i;
      buf.write(digits[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(" ");
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ProviderAddServiceScreen extends StatefulWidget {
  const ProviderAddServiceScreen({super.key});

  @override
  State<ProviderAddServiceScreen> createState() =>
      _ProviderAddServiceScreenState();
}

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  final store = ServiceStore.instance;

  final List<String> _serviceOptions = const [
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

  String? _selectedService;
  final Set<String> _districts = {}; // I..XXIII – popupban választjuk

  final priceCtrl = TextEditingController();
  PriceUnit _unit = PriceUnit.ftPerHour;

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
    final current = Set<String>.from(_districts);

    final result = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text("Budapest, kerületek"),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                FilterChip(
                  label: const Text("Mind"),
                  selected: current.length == all.length,
                  onSelected: (v) {
                    setLocal(() {
                      current
                        ..clear()
                        ..addAll(v ? all : const <String>[]);
                    });
                  },
                ),
                ...all.map((d) => FilterChip(
                  label: Text(d),
                  selected: current.contains(d),
                  onSelected: (v) =>
                      setLocal(() => v ? current.add(d) : current.remove(d)),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Mégse")),
            FilledButton(onPressed: () => Navigator.pop(ctx, current), child: const Text("Mentés")),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _districts
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _addSlot() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) return;
    final from = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: "Kezdő idő",
    );
    if (from == null) return;
    final to = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 16, minute: 0),
      helpText: "Záró idő",
    );
    if (to == null) return;

    setState(() {
      _slots.add(ServiceSlot(
        date: DateTime(date.year, date.month, date.day),
        from: from,
        to: to,
      ));
    });
  }

  void _removeSlot(int i) => setState(() => _slots.removeAt(i));

  void _save() {
    final priceDigits = priceCtrl.text.replaceAll(" ", "");
    if (_selectedService == null ||
        _districts.isEmpty ||
        priceDigits.isEmpty ||
        _slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Tölts ki mindent: szolgáltatás, kerület(ek), ár, idősávok.")));
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

  String two(int n) => n.toString().padLeft(2, "0");

  @override
  Widget build(BuildContext context) {
    // szerkesztéskor előtöltés
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int) {
      final s = store.services[arg];
      _selectedService ??= s.name;
      if (_districts.isEmpty) _districts.addAll(s.districts);
      if (priceCtrl.text.isEmpty) {
        final t = s.price.toString();
        final buf = StringBuffer();
        for (int i = 0; i < t.length; i++) {
          final idxFromEnd = t.length - i;
          buf.write(t[i]);
          if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(" ");
        }
        priceCtrl.text = buf.toString();
      }
      if (_slots.isEmpty) _slots.addAll(s.slots);
      _unit = s.unit;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Új szolgáltatás")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 6, runSpacing: 6,
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

            Row(
              children: [
                const Expanded(child: Text("Budapest, kerületek")),
                TextButton(onPressed: _pickDistricts, child: const Text("Kiválasztás")),
              ],
            ),
            Text(
              _districts.isEmpty ? "Nincs kiválasztva" : (_districts.toList()..sort()).join(", "),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsFormatter()],
                    decoration: const InputDecoration(
                      labelText: "Ár",
                      hintText: "pl. 12 000",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ToggleButtons(
                  isSelected: [_unit == PriceUnit.ftPerHour, _unit == PriceUnit.ftPerSqm],
                  onPressed: (i) => setState(() =>
                    _unit = i == 0 ? PriceUnit.ftPerHour : PriceUnit.ftPerSqm),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("Ft/óra")),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("Ft/nm")),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Expanded(child: Text("Elérhetőség (nap + óra/perc)")),
                TextButton(onPressed: _addSlot, child: const Text("Hozzáadás")),
              ],
            ),
            if (_slots.isNotEmpty)
              Wrap(
                spacing: 6, runSpacing: 6,
                children: List.generate(_slots.length, (i) {
                  final s = _slots[i];
                  final d = "${s.date.year}.${two(s.date.month)}.${two(s.date.day)}.";
                  final f = "${two(s.from.hour)}:${two(s.from.minute)}";
                  final t = "${two(s.to.hour)}:${two(s.to.minute)}";
                  return InputChip(
                    label: Text("$d • $f–$t"),
                    onDeleted: () => _removeSlot(i),
                  );
                }),
              )
            else
              const Text("Nincs idősáv megadva"),
            const Spacer(),
            FilledButton(onPressed: _save, child: const Text("Mentés")),
          ],
        ),
      ),
    );
  }
}
