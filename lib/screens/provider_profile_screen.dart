import 'package:flutter/material.dart';

class ProviderProfileScreen extends StatelessWidget {
  final List<String> services;
  final List<int> districts;
  final String rate;
  final TimeOfDay weekdayFrom;
  final TimeOfDay weekdayTo;
  final TimeOfDay weekendFrom;
  final TimeOfDay weekendTo;
  final String? description;

  const ProviderProfileScreen({
    super.key,
    required this.services,
    required this.districts,
    required this.rate,
    required this.weekdayFrom,
    required this.weekdayTo,
    required this.weekendFrom,
    required this.weekendTo,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(color: Colors.grey.shade700);

    return Scaffold(
      appBar: AppBar(title: const Text('Szolgáltatói profil')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // vissza a setupra új szolgáltatás felvételéhez
          Navigator.pop(context);
        },
        child: const Icon(Icons.add),
        tooltip: 'Új szolgáltatás felvétele',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // publikus fejléc (demó avatar)
            Row(
              children: const [
                CircleAvatar(radius: 28, child: Icon(Icons.person)),
                SizedBox(width: 12),
                Text('Szolgáltató (demó név)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),

            Text('Értékelés és statisztika', style: labelStyle),
            const SizedBox(height: 6),
            const Text('⭐ 4.8 • 12 db sikeres teljesítés'),
            const SizedBox(height: 16),

            Text('Szolgáltatások', style: labelStyle),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: services.map((s) => Chip(label: Text(s))).toList(),
            ),
            const SizedBox(height: 16),

            Text('Kerületek', style: labelStyle),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: districts.map((d) => Chip(label: Text('$d.'))).toList(),
            ),
            const SizedBox(height: 16),

            Text('Árazás', style: labelStyle),
            const SizedBox(height: 6),
            Text('$rate Ft/óra'),
            const SizedBox(height: 16),

            Text('Elérhetőség', style: labelStyle),
            const SizedBox(height: 6),
            Text('Hétköznap: ${weekdayFrom.format(context)} - ${weekdayTo.format(context)}'),
            Text('Hétvége: ${weekendFrom.format(context)} - ${weekendTo.format(context)}'),
            const SizedBox(height: 16),

            if (description != null && description!.isNotEmpty) ...[
              Text('Bemutatkozás', style: labelStyle),
              const SizedBox(height: 6),
              Text(description!),
              const SizedBox(height: 16),
            ],

            Text('Legutóbbi 3 munka', style: labelStyle),
            const SizedBox(height: 6),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Általános takarítás – 2025-08-10 10:00'),
              subtitle: Text('XIII. kerület, Demó utca 1.'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Vízszerelés – 2025-08-05 14:00'),
              subtitle: Text('II. kerület, Minta u. 2.'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Villanyszerelés – 2025-07-28 09:00'),
              subtitle: Text('XI. kerület, Próba tér 3.'),
            ),
          ],
        ),
      ),
    );
  }
}
