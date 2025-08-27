import 'package:flutter/material.dart';
import '../widgets/district_picker.dart';

class ProviderProfileSetupScreen extends StatefulWidget {
  const ProviderProfileSetupScreen({super.key});

  @override
  State<ProviderProfileSetupScreen> createState() => _ProviderProfileSetupScreenState();
}

class _ProviderProfileSetupScreenState extends State<ProviderProfileSetupScreen> {
  List<int> _districts = [];
  String? _service;
  final _rateCtrl = TextEditingController(text: '12000');
  TimeOfDay _wdFrom = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _wdTo = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _weFrom = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _weTo = const TimeOfDay(hour: 16, minute: 0);

  final List<String> _services = const [
    'Apartman takarítás','Általános takarítás','Nagytakarítás','Felújítás utáni takarítás',
    'Karbantartás','Vízszerelés','Gázszerelés','Légkondicionáló szerelés','Bútorösszeszerelés','Villanyszerelés',
  ];

  bool get _canSave =>
      _service != null && _districts.isNotEmpty && _rateCtrl.text.trim().isNotEmpty;

  Future<void> _pickTime(bool weekday, bool from) async {
    final initial = from ? (weekday ? _wdFrom : _weFrom) : (weekday ? _wdTo : _weTo);
    final res = await showTimePicker(context: context, initialTime: initial);
    if (res == null) return;
    setState(() {
      if (weekday) {
        if (from) _wdFrom = res; else _wdTo = res;
      } else {
        if (from) _weFrom = res; else _weTo = res;
      }
    });
  }

  void _save() {
    if (!_canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kerület, szolgáltatás és óradíj kötelező')),
      );
      return;
    }
    Navigator.pushReplacementNamed(context, '/provider/profile');
  }

  @override
  Widget build(BuildContext context) {
    final summary = summarizeDistricts(_districts);

    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltatás felvétele')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column( // nincs görgetés
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Budapest + kerületválasztó
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Budapest'),
              subtitle: Text(summary),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final res = await pickDistricts(context, _districts);
                if (res != null) setState(() => _districts = res);
              },
            ),
            const Divider(),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Szolgáltatás (egy választás)'),
              items: _services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _service = v),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _rateCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Óradíj (Ft/óra)'),
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Text('Hétköznap: ${_wdFrom.format(context)}–${_wdTo.format(context)}')),
                IconButton(onPressed: () => _pickTime(true, true), icon: const Icon(Icons.schedule)),
                IconButton(onPressed: () => _pickTime(true, false), icon: const Icon(Icons.schedule)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('Hétvége: ${_weFrom.format(context)}–${_weTo.format(context)}')),
                IconButton(onPressed: () => _pickTime(false, true), icon: const Icon(Icons.schedule)),
                IconButton(onPressed: () => _pickTime(false, false), icon: const Icon(Icons.schedule)),
              ],
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: _canSave ? _save : null,
              child: const Text('Mentés'),
            ),
          ],
        ),
      ),
    );
  }
}
