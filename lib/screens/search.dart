// lib/screens/search.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../utils.dart';
import '../models.dart';
import 'offers.dart';

class SearchScreen extends StatefulWidget {
  final UserRole role;
  const SearchScreen({super.key, required this.role});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Szolgáltatások (JSON-ből)
  List<Map<String, dynamic>> services = [];
  String? selectedServiceId;

  // Kerület
  int selectedDistrict = 13;

  // Cím + időpont
  final TextEditingController streetCtrl = TextEditingController();
  DateTime? startAt;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final raw = await rootBundle.loadString('assets/services.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = (data['services'] as List).cast<Map<String, dynamic>>();
    setState(() {
      services = list;
      if (services.isNotEmpty) {
        selectedServiceId = services.first['id'] as String;
      }
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
      initialDate: now,
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      startAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          Text("Szolgáltatás", style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 6),

          // --- JAVÍTVA: Típusos dropdown (String) ---
          if (services.isEmpty)
            const LinearProgressIndicator()
          else
            DropdownButtonFormField<String>(
              value: selectedServiceId,
              onChanged: (v) => setState(() => selectedServiceId = v),
              items: services
                  .map<DropdownMenuItem<String>>(
                    (s) => DropdownMenuItem<String>(
                      value: s['id'] as String,
                      child: Text(s['label'] as String),
                    ),
                  )
                  .toList(),
            ),

          const SizedBox(height: 16),
          Text("Kerület", style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 6),

          // Kerület dropdown (int) – ez jó volt
          DropdownButtonFormField<int>(
            value: selectedDistrict,
            onChanged: (v) => setState(() => selectedDistrict = v ?? 13),
            items: budapestDistricts
                .map<DropdownMenuItem<int>>(
                  (d) => DropdownMenuItem<int>(
                    value: d,
                    child: Text(districtLabel(d)),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 16),
          Text("Utca", style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          TextField(
            controller: streetCtrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "pl. Váci út 12.",
            ),
          ),

          const SizedBox(height: 16),
          Text("Kezdés időpontja", style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  startAt == null ? "nincs kiválasztva" : startAt.toString().substring(0, 16),
                ),
              ),
              FilledButton(
                onPressed: _pickDateTime,
                child: const Text("Választás"),
              ),
            ],
          ),

          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Ajánlatkérés"),
            onPressed: () {
              if (selectedServiceId == null ||
                  startAt == null ||
                  streetCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tölts ki minden mezőt!")),
                );
                return;
              }
              final req = OfferRequest(
                serviceId: selectedServiceId!,
                district: selectedDistrict,
                street: streetCtrl.text.trim(),
                startAt: startAt!,
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OffersScreen(request: req)),
              );
            },
          ),
        ],
      ),
    );
  }
}
