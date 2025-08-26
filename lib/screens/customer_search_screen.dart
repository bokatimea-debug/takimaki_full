import 'package:flutter/material.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _streetCtrl = TextEditingController();
  String _selectedService = 'apartment_cleaning';
  int _selectedDistrict = 13;
  DateTime? _startAt;

  final _services = const <Map<String, String>>[
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

  List<int> get _districts => List<int>.generate(23, (i) => i + 1);

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
      initialDate: now,
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      _startAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _requestQuotes() {
    if (_streetCtrl.text.trim().isEmpty || _startAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utca és időpont kötelező')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajánlatkérés elküldve'),
        content: Text(
          'Szolgáltatás: ${_services.firstWhere((s) => s['id'] == _selectedService)['label']}\n'
          'Kerület: ${_selectedDistrict}\n'
          'Utca: ${_streetCtrl.text}\n'
          'Időpont: ${_startAt!.toString().substring(0,16)}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(color: Colors.grey.shade700);
    return Scaffold(
      appBar: AppBar(title: const Text('Keresés')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Szolgáltatás', style: labelStyle),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedService,
              items: _services
                  .map<DropdownMenuItem<String>>(
                    (s) => DropdownMenuItem<String>(
                      value: s['id']!,
                      child: Text(s['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedService = v ?? _selectedService),
            ),
            const SizedBox(height: 14),
            Text('Kerület', style: labelStyle),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _selectedDistrict,
              items: _districts
                  .map<DropdownMenuItem<int>>(
                    (d) => DropdownMenuItem<int>(value: d, child: Text('Budapest ${d}. kerület')),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedDistrict = v ?? _selectedDistrict),
            ),
            const SizedBox(height: 14),
            Text('Utca', style: labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _streetCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'pl. Váci út 12.',
              ),
            ),
            const SizedBox(height: 14),
            Text('Kezdés időpontja', style: labelStyle),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _startAt == null ? 'nincs kiválasztva' : _startAt!.toString().substring(0, 16),
                  ),
                ),
                FilledButton(onPressed: _pickDateTime, child: const Text('Választás')),
              ],
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _requestQuotes,
              icon: const Icon(Icons.send),
              label: const Text('Ajánlatkérés'),
            ),
          ],
        ),
      ),
    );
  }
}
