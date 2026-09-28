import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final order = args is Map ? Map<String, dynamic>.from(args) : <String, dynamic>{};

    String value(String key, [String fallback = 'Nincs megadva']) {
      final result = order[key]?.toString().trim() ?? '';
      return result.isEmpty ? fallback : result;
    }

    final when = order['when']?.toString() ??
        [order['date'], order['time']]
            .where((item) => item != null && item.toString().isNotEmpty)
            .join(' • ');

    return Scaffold(
      appBar: AppBar(title: const Text('Rendelés részletei')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            value('service', value('title')),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _Detail(icon: Icons.person_outline, label: 'Partner', value: value('customer', value('provider'))),
          _Detail(icon: Icons.location_on_outlined, label: 'Helyszín', value: value('address')),
          _Detail(icon: Icons.calendar_today_outlined, label: 'Időpont', value: when.isEmpty ? 'Nincs megadva' : when),
          _Detail(icon: Icons.payments_outlined, label: 'Ár', value: value('price', value('offered_price'))),
          _Detail(icon: Icons.info_outline, label: 'Státusz', value: value('status')),
          if ((order['rating'] as num?) != null)
            _Detail(icon: Icons.star_outline, label: 'Értékelés', value: '${order['rating']} / 5'),
          if (value('note', '').isNotEmpty)
            _Detail(icon: Icons.notes, label: 'Megjegyzés', value: value('note')),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
      ),
    );
  }
}
