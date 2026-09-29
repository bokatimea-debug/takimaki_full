import 'package:flutter/material.dart';

import '../services/demo_data.dart';
import '../services/local_marketplace_store.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await LocalMarketplaceStore.customerOrders();
    _items = saved.isNotEmpty
        ? saved
        : DemoOrders.customerOrders
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rendeléseim')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = _items[index];
            final title = item['service'] ?? item['title'] ?? '';
            final date = item['date'] ?? '';
            final time = item['time'] ?? '';
            final status = item['status'] ?? '';
            return Card(
              child: ListTile(
                title: Text(title.toString()),
                subtitle: Text('$date $time • $status'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/order/details',
                  arguments: {...item, 'view_role': 'customer'},
                ).then((_) => _load()),
              ),
            );
          },
        ),
      ),
    );
  }
}
