import 'package:flutter/material.dart';
import 'provider_profile_screen.dart';

class ProviderProfileSetupScreen extends StatefulWidget {
  const ProviderProfileSetupScreen({super.key});

  @override
  State<ProviderProfileSetupScreen> createState() => _ProviderProfileSetupScreenState();
}

class _ProviderProfileSetupScreenState extends State<ProviderProfileSetupScreen> {
  final _rate = TextEditingController(text: '12000');
  final _desc = TextEditingController();

  // szolgáltatás katalógus
  final List<Map<String, String>> _catalog = const [
    {'id': 'apartment_cleaning', 'label': 'Apartman takarítás'},
    {'id': 'general_cleaning', 'label': 'Általános takarítás'},
    {'id': 'deep_cleaning', 'label': 'Nagytakarítás'},
    {'id': 'post_renovation', 'label': 'Felújítás utáni takarítás'},
    {'id': 'maintenance', 'label': 'Karbantartás'},
    {'id': 'plumbing', 'label': 'Vízszerelés'},
    {'id': 'gas', 'label': 'Gázszerelés'},
    {'id': 'aircon', 'label': 'Légkondicionáló szerelés'},
    {'id': 'furniture', 'label': 'Bútorösszeszerelés'},
    {'id': 'electricity', 'label': 'Villanyszerelés'},
  ];

  // kiválasztott szolgáltatások
  final List<String> _selectedServiceIds = ['general_cleaning'];

  // kerületek
  final Set<int> _districts = {13};

  // elérhetőség
  TimeOfDay _wkFrom = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _wkTo   = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _weFrom = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _weTo   = const TimeOfDay(hour: 16, minute: 0);

  List<int> get _allDistricts => List<int>.generate(23, (i) => i + 1);

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) =>
      showTimePicker(context: context, initialTime: initial);

  void _addService() async {
    // elérhető (még fel nem vett) szolgáltatások
    final remaining = _catalog.where((s) => !_selectedServiceIds.contains(s['id'])).toList();
    if (remaining.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minden szolgáltatás felvéve')));
      return;
    }
    String? chosenId;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Új szolgáltatás felvétele'),
        content: DropdownButtonFormField<String>(
          items: remaining
              .map((s) => DropdownMenuItem(value: s['id']!, child: Text(s['label']!)))
              .toList(),
          onChanged: (v) => chosenId = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mégse')),
          FilledButton(
            onPressed: () {
              if (chosenId != null) {
                setState(() => _selectedServiceIds.add(chosenId!));
              }
              Navigator.pop(context);
            },
            child: const Text('Hozzáadás'),
          ),
        ],
      ),
    );
  }

  void _removeService(String id) {
    setState(() => _selectedServiceIds.remove(id));
  }

  String _labelOf(String id) =>
      _catalog.firstWhere((s) => s['id'] == id)['label'] ?? id;

  void _saveAndOpenProfile() {
    if (_selectedServiceIds.isEmpty || _districts.isEmpty || _rate.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Szolgáltatás, kerület és óradíj kötelező')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderProfileScreen(
          services: _selectedServiceIds.map(_labelOf).toList(),
          districts: (_districts.toList()..sort()),
          rate: _rate.text.trim(),
          weekdayFrom: _wkFrom,
          weekdayTo: _wkTo,
          weekendFrom: _weFrom,
          weekendTo: _weTo,
          description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(color: Colors.grey.shade700);

    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltatói adatlap')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addService,
        icon: const Icon(Icons.add),
        label: const Text('Szolgáltatás'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Felvett szolgáltatások', style: labelStyle),
            const SizedBox(height: 8),
            if (_selectedServiceIds.isEmpty)
              const Text('Nincs felvett szolgáltatás'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedServiceIds
                  .map((id) => Chip(
                        label: Text(_labelOf(id)),
                        onDeleted: () => _removeService(id),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            Text('Kerületek (I–XXIII)', style: labelStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _allDistricts
                  .map((d) => FilterChip(
                        label: Text('$d.'),
                        selected: _districts.contains(d),
                        onSelected: (sel) => setState(() {
                          sel ? _districts.add(d) : _districts.remove(d);
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            Text('Óradíj (Ft/óra)', style: labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _rate,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'pl. 12000'),
            ),
            const SizedBox(height: 16),

            Text('Rövid leírás (opcionális)', style: labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _desc,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Pár mondat magadról...'),
            ),
            const SizedBox(height: 16),

            Text('Elérhetőség', style: labelStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Hétköznap: ${_wkFrom.format(context)} - ${_wkTo.format(context)}')),
                IconButton(
                  onPressed: () async {
                    final f = await _pickTime(_wkFrom);
                    if (f == null) return;
                    final t = await _pickTime(_wkTo);
                    if (t == null) return;
                    setState(() {
                      _wkFrom = f;
                      _wkTo = t;
                    });
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('Hétvége: ${_weFrom.format(context)} - ${_weTo.format(context)}')),
                IconButton(
                  onPressed: () async {
                    final f = await _pickTime(_weFrom);
                    if (f == null) return;
                    final t = await _pickTime(_weTo);
                    if (t == null) return;
                    setState(() {
                      _weFrom = f;
                      _weTo = t;
                    });
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _saveAndOpenProfile,
              icon: const Icon(Icons.save),
              label: const Text('Mentés és profil megnyitása'),
            ),
          ],
        ),
      ),
    );
  }
}
