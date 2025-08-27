import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  // kiválasztott szolgáltatás(ok) – most 1-esével vesszük fel
  String? selectedService;
  final List<String> servicesCatalog = const [
    'Általános takarítás',
    'Nagytakarítás',
    'Irodatakarítás',
    'Ablaktisztítás',
    'Kárpittisztítás'
  ];
  final List<String> savedServices = [];

  // kerületek – rejtett választó (I–XXIII)
  final Set<int> selectedDistricts = {};
  bool showDistrictPicker = false;

  // óradíj + rövid leírás
  final TextEditingController hourlyCtrl = TextEditingController(text: '12000');
  final TextEditingController aboutCtrl = TextEditingController();

  // elérhetőség (csak két rövid mező, hogy kiférjen egy képernyőre)
  TimeOfDay? weekdayFrom = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay? weekdayTo = const TimeOfDay(hour: 18, minute: 0);

  String roman(int n) {
    const map = {
      1: 'I', 2: 'II', 3: 'III', 4: 'IV', 5: 'V', 6: 'VI',
      7: 'VII', 8: 'VIII', 9: 'IX', 10: 'X', 11: 'XI', 12: 'XII',
      13: 'XIII', 14: 'XIV', 15: 'XV', 16: 'XVI', 17: 'XVII', 18: 'XVIII',
      19: 'XIX', 20: 'XX', 21: 'XXI', 22: 'XXII', 23: 'XXIII'
    };
    return map[n]!;
  }

  Future<TimeOfDay?> pickTime(TimeOfDay initial) async {
    final res = await showTimePicker(context: context, initialTime: initial);
    return res;
  }

  void addService() {
    if (selectedService == null) return;
    if (!savedServices.contains(selectedService)) {
      setState(() => savedServices.add(selectedService!));
    }
  }

  Future<void> saveProfile() async {
    if (savedServices.isEmpty) {
      _snack('Adj hozzá legalább 1 szolgáltatást!');
      return;
    }
    if (selectedDistricts.isEmpty) {
      _snack('Válassz legalább 1 kerületet!');
      return;
    }
    if (weekdayFrom == null || weekdayTo == null) {
      _snack('Állítsd be az elérhetőséget!');
      return;
    }

    // DEMO: itt normál esetben mentenénk (backend / storage)
    final availability =
        '${weekdayFrom!.format(context)} – ${weekdayTo!.format(context)}';
    final districts = selectedDistricts.toList()..sort();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Profil elmentve'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Szolgáltatások: ${savedServices.join(", ")}'),
            const SizedBox(height: 6),
            Text('Terület: Budapest, ${districts.map(roman).join(", ")}'),
            const SizedBox(height: 6),
            Text('Óradíj: ${NumberFormat("#,###").format(int.tryParse(hourlyCtrl.text) ?? 0)} Ft'),
            const SizedBox(height: 6),
            Text('Elérhetőség: $availability'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProviderProfileSummaryScreen(
                    services: List<String>.from(savedServices),
                    districts: districts,
                    hourly: int.tryParse(hourlyCtrl.text) ?? 0,
                    availability: availability,
                  ),
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final pad = EdgeInsets.symmetric(
      horizontal: 16,
      vertical: MediaQuery.of(context).size.height < 750 ? 6 : 10,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltatói adatlap')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budapest felirat + kerület választó gomb
            Row(
              children: [
                const Text('Budapest',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.map),
                  label: Text(
                    selectedDistricts.isEmpty
                        ? 'Kerületek kiválasztása'
                        : 'Kerületek (${selectedDistricts.length})',
                  ),
                  onPressed: () => setState(() {
                    showDistrictPicker = true;
                  }),
                ),
              ],
            ),
            if (selectedDistricts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final d in (selectedDistricts.toList()..sort()))
                      Chip(
                        label: Text(roman(d)),
                        onDeleted: () =>
                            setState(() => selectedDistricts.remove(d)),
                      ),
                  ],
                ),
              ),

            // Szolgáltatás választó + Hozzáadás
            Padding(
              padding: pad,
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedService,
                      decoration: const InputDecoration(
                        labelText: 'Szolgáltatás',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: servicesCatalog
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedService = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: addService,
                    icon: const Icon(Icons.add),
                    label: const Text('Felvétel'),
                  ),
                ],
              ),
            ),

            if (savedServices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in savedServices)
                      Chip(
                        label: Text(s),
                        onDeleted: () =>
                            setState(() => savedServices.remove(s)),
                      ),
                  ],
                ),
              ),

            // óradíj + rövid leírás + elérhetőség
            Padding(
              padding: pad,
              child: TextField(
                controller: hourlyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Óradíj (Ft/óra)',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: pad,
              child: TextField(
                controller: aboutCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Rövid leírás (opcionális)',
                  hintText: 'Pár mondat magadról…',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: pad,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final t = await pickTime(weekdayFrom!);
                        if (t != null) setState(() => weekdayFrom = t);
                      },
                      child:
                          Text('Hétköznap: ${weekdayFrom!.format(context)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final t = await pickTime(weekdayTo!);
                        if (t != null) setState(() => weekdayTo = t);
                      },
                      child: Text('— ${weekdayTo!.format(context)}'),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: FilledButton.icon(
                onPressed: saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Mentés'),
              ),
            ),
          ],
        ),
      ),

      // kerületválasztó modal (rejtve, míg nem kérik)
      bottomSheet: showDistrictPicker
          ? _DistrictPickerSheet(
              initial: selectedDistricts,
              roman: roman,
              onClose: () => setState(() => showDistrictPicker = false),
              onChanged: (set) =>
                  setState(() => selectedDistricts
                    ..clear()
                    ..addAll(set)),
            )
          : null,
    );
  }
}

class _DistrictPickerSheet extends StatelessWidget {
  final Set<int> initial;
  final String Function(int) roman;
  final VoidCallback onClose;
  final ValueChanged<Set<int>> onChanged;

  const _DistrictPickerSheet({
    required this.initial,
    required this.roman,
    required this.onClose,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sel = Set<int>.from(initial);
    return Material(
      elevation: 12,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Kerületek (I–XXIII)',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                  IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 1; i <= 23; i++)
                    FilterChip(
                      label: Text(roman(i)),
                      selected: sel.contains(i),
                      onSelected: (v) {
                        if (v) {
                          sel.add(i);
                        } else {
                          sel.remove(i);
                        }
                        onChanged(sel);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProviderProfileSummaryScreen extends StatelessWidget {
  final List<String> services;
  final List<int> districts;
  final int hourly;
  final String availability;

  const ProviderProfileSummaryScreen({
    super.key,
    required this.services,
    required this.districts,
    required this.hourly,
    required this.availability,
  });

  String roman(int n) {
    const map = {
      1: 'I', 2: 'II', 3: 'III', 4: 'IV', 5: 'V', 6: 'VI',
      7: 'VII', 8: 'VIII', 9: 'IX', 10: 'X', 11: 'XI', 12: 'XII',
      13: 'XIII', 14: 'XIV', 15: 'XV', 16: 'XVI', 17: 'XVII', 18: 'XVIII',
      19: 'XIX', 20: 'XX', 21: 'XXI', 22: 'XXII', 23: 'XXIII'
    };
    return map[n]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil összegzés')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Felvett szolgáltatások',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final s in services) Chip(label: Text(s))],
            ),
            const SizedBox(height: 12),
            Text(
              'Terület: Budapest, ${districts.map(roman).join(", ")}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text('Óradíj: ${NumberFormat("#,###").format(hourly)} Ft'),
            const SizedBox(height: 8),
            Text('Elérhetőség: $availability'),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProviderProfileScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Szolgáltatás hozzáadása'),
            ),
          ],
        ),
      ),
    );
  }
}
