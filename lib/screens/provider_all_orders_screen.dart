import 'package:flutter/material.dart';

class ProviderAllOrdersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> orders; // illeszd a meglévő adatforrásodhoz
  const ProviderAllOrdersScreen({super.key, this.orders = const []});

  @override
  Widget build(BuildContext context) {
    final list = orders; // cseréld Firestore streamre a projekt logikád szerint
    return Scaffold(
      appBar: AppBar(title: const Text('Összes rendelés')),
      body: ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final o = list[i];
          final rating = (o['rating'] as num?)?.toDouble();
          final review = (o['review'] ?? '').toString();
          return ListTile(
            title: Text(o['title'] ?? 'Rendelés'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o['dateStr'] ?? ''),
                if (rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (idx) {
                      final filled = rating >= (idx + 1);
                      return Icon(
                        filled ? Icons.star : (rating > idx ? Icons.star_half : Icons.star_border),
                        color: Colors.amber,
                        size: 18,
                      );
                    }),
                  ),
                  if (review.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('"$review"'),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
