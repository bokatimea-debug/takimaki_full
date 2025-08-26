import 'package:flutter/material.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _streetCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  String? _selectedService;
  String? _selectedDistrict;

  final List<String> _services = [
    'Apartman takarítás',
    'Általános takarítás',
    'Nagytakarítás',
    'Felújítás utáni takarítás',
    'Karbantartás',
    'Vízszerelés',
    'Gázszerelés',
    'Légkondicionáló szerelés',
    'Bútorösszeszerelés',
    'Villanyszerelés',
  ];

  final List<String> _districts = [
    for (int i = 1; i <= 23; i++) '$i. kerület',
  ];

  void _search() {
    if (_selectedService == null ||
        _selectedDistrict == null ||
        _streetCtrl.text.trim().isEmpty ||
        _dateCtrl.text.trim().isEmpty ||
        _timeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minden mező kötelező!')),
      );
      return;
    }

    // Itt később: ajánlatkérés logika -> most: ugrás a profilra
    Navigator.pushNamed(context, '/customer/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltató keresése')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Szolgáltatás'),
              items: _services
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedService = val),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Kerület'),
              items: _districts
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedDistrict = val),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _streetCtrl,
              decoration: const InputDecoration(
                labelText: 'Utca',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _dateCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Dátum',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDate: DateTime.now(),
                );
                if (picked != null) {
                  _dateCtrl.text = '${picked.year}-${picked.month}-${picked.day}';
                }
              },
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _timeCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Idő',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  _timeCtrl.text = picked.format(context);
                }
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _search,
              child: const Text('Keresés'),
            ),
          ],
        ),
      ),
    );
  }
}
