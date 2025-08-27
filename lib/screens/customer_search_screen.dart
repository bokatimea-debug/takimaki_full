import 'package:flutter/material.dart';
import '../widgets/district_picker.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _streetCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  String? _service;
  List<int> _districts = []; // 1..23

  final List<String> _services = const [
    'Apartman takarítás','Általános takarítás','Nagytakarítás','Felújítás utáni takarítás',
    'Karbantartás','Vízszerelés','Gázszerelés','Légkondicionáló szerelés','Bútorösszeszerelés','Villanyszerelés',
  ];

  void _openDistricts() async {
    final res = await pickDistricts(context, _districts);
    if (res != null) setState(() => _districts = res);
  }

  void _search() {
    if (_service == null ||
        _districts.isEmpty ||
        _streetCtrl.text.trim().isEmpty ||
        _dateCtrl.text.trim().isEmpty ||
        _timeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minden mező kötelező'), duration: Duration(seconds: 2)),
      );
      return;
    }
    Navigator.pushNamed(context, '/customer/profile');
  }

  @override
  Widget build(BuildContext context) {
    final summary = summarizeDistricts(_districts);

    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltató keresése')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column( // nincs görgetés
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Szolgáltatás'),
              items: _services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _service = v),
            ),
            const SizedBox(height: 10),

            // Budapest fix + kerületválasztó modal
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Budapest'),
              subtitle: Text(summary),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openDistricts,
            ),
            const Divider(),

            TextField(
              controller: _streetCtrl,
              decoration: const InputDecoration(labelText: 'Utca, házszám'),
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Dátum'),
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 365)),
                        initialDate: now,
                      );
                      if (picked != null) {
                        _dateCtrl.text = '${picked.year}-${picked.month}-${picked.day}';
                        setState(() {});
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _timeCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Idő'),
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (picked != null) {
                        _timeCtrl.text = picked.format(context);
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),

            const Spacer(),
            ElevatedButton(onPressed: _search, child: const Text('Keresés')),
          ],
        ),
      ),
    );
  }
}

