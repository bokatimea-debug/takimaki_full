import "package:flutter/material.dart";

import "../services/local_marketplace_store.dart";

class ProviderAllOrdersScreen extends StatefulWidget {
  const ProviderAllOrdersScreen({super.key});
  @override
  State<ProviderAllOrdersScreen> createState() =>
      _ProviderAllOrdersScreenState();
}

class _ProviderAllOrdersScreenState extends State<ProviderAllOrdersScreen> {
  List<Map<String, dynamic>> _items = [];

  Future<void> _load() async {
    _items = await LocalMarketplaceStore.providerOrders();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Widget _stars(int n) {
    n = n.clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < n;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Összes rendelés")),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _items.isEmpty ? 1 : _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          if (_items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Column(
                children: [
                  Icon(Icons.work_outline, size: 56),
                  SizedBox(height: 12),
                  Text("Még nincs elfogadott munkád."),
                ],
              ),
            );
          }
          final it = _items[i];
          final title = it["service"] ?? "";
          final when = it["when"] ?? "${it['date'] ?? ''} ${it['time'] ?? ''}";
          final rating = (it["rating"] as num?)?.toInt() ?? 0;
          return Card(
            child: ListTile(
              title: Text(title),
              subtitle: Text(when),
              trailing: _stars(rating),
              onTap: () => Navigator.pushNamed(
                context,
                '/order/details',
                arguments: {...it, 'view_role': 'provider'},
              ).then((_) => _load()),
            ),
          );
        },
      ),
    );
  }
}
