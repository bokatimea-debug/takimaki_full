import 'package:flutter/material.dart';

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
    _items = await LocalMarketplaceStore.customerOrders();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rendeléseim')),
      floatingActionButton: _items.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/customer/search'),
              icon: const Icon(Icons.add),
              label: const Text('Új rendelés'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _items.isEmpty ? 1 : _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (_items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 56),
                    SizedBox(height: 12),
                    Text('Még nincs rendelésed.'),
                  ],
                ),
              );
            }
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
