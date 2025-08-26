import 'package:flutter/material.dart';

class ProviderProfileSetupScreen extends StatefulWidget {
  const ProviderProfileSetupScreen({super.key});

  @override
  State<ProviderProfileSetupScreen> createState() => _ProviderProfileSetupScreenState();
}

class _ProviderProfileSetupScreenState extends State<ProviderProfileSetupScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _rate = TextEditingController(text: '12000');
  String _service = 'general_cleaning';
  final Set<int> _districts = {13};
  TimeOfDay _wkFrom = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _wkTo = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _weFrom = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _weTo = const TimeOfDay(hour: 16, minute: 0);

  final _services = const <Map<String, String>>[
    {'id': 'apartment_cleaning', 'label': 'Apartman takarítás'},
    {'id': 'general_cleaning', 'label': 'Általános takarítás'},
    {'id': 'deep_cleaning', 'label': 'Nagytakarítás'},
    {'id': 'plumbing', 'label': 'Vízszerelés'},
    {'id': 'gas', 'label': 'Gázszerelés'},
    {'id': 'aircon', 'label': 'Légkondicionáló szerelés'},
    {'id': 'furniture', 'label': 'Bútorösszeszerelés'},
    {'id': 'electricity', 'label': 'Villanyszerelés'},
  ];

  List<int> get _allDistricts => List<int>.generate(23, (i) => i + 1);

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) =>
      showTimePicker(context: context, initialTime: initial);

  void _save() {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Név és telefonszám kötelező')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Profil elmentve (demó)'),
        content: Text(
          'Név: ${_name.text}\n'
          'Szolgáltatás: ${_services.firstWhere((s) => s['id'] == _service)['label']}\n'
          'Kerületek: ${_districts.toList()..sort()}\n'
          'Óradíj: ${_rate.text} Ft\n'
          'Hétköznap: ${_wkFrom.format(context)} - ${_wkTo.format(context)}\n'
          'Hétvége: ${_weFrom.format(context)} - ${_weTo.format(context)}',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(color: Colors.grey.shade700);
    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltatói profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Név', style: labelStyle),
            const SizedBox(height: 6),
            TextField(controller: _name, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Text('Telefonszám', style: labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Text('Szolgáltatás', style: labelStyle),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _service,
              items: _services
                  .map<DropdownMenuItem<String>>(
                    (s) => DropdownMenuItem<String>(
                      value: s['id']!,
                      child: Text(s['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _service = v ?? _service),
            ),
            const SizedBox(height: 12),
            Text('Kerületek (több választható)', style: labelStyle),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _allDistricts
                  .map((d) => FilterChip(
                        label: Text('$d.'),
                        selected: _districts.contains(d),
                        onSelected: (sel) => setState(() {
                          if (sel) {
                            _districts.add(d);
                          } else {
                            _districts.remove(d);
                          }
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text('Óradíj (Ft/óra)', style: labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _rate,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Text('Elérhetőség', style: labelStyle),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: Text('Hétköznap: ${_wkFrom.format(context)} - ${_wkTo.format(context)}')),
                IconButton(
                  onPressed: () async {
                    final from = await _pickTime(_wkFrom);
                    if (from == null) return;
                    final to = await _pickTime(_wkTo);
                    if (to == null) return;
                    setState(() {
                      _wkFrom = from;
                      _wkTo = to;
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
                    final from = await _pickTime(_weFrom);
                    if (from == null) return;
                    final to = await _pickTime(_weTo);
                    if (to == null) return;
                    setState(() {
                      _weFrom = from;
                      _weTo = to;
                    });
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Mentés'),
            ),
          ],
        ),
      ),
    );
  }
}
