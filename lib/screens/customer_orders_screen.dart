import '../widgets/service_choice_grid.dart';
import '../widgets/taki_app_bar.dart';

import 'package:flutter/material.dart';

import '../services/local_marketplace_store.dart';
import '../theme.dart';
import '../widgets/branded_background.dart';
import '../utils/work_schedule.dart';
import 'customer_search_screen.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});
  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _orders = await LocalMarketplaceStore.customerOrders();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Rendeléseim')),
    body: BrandedBackground(
      child: _orders.isEmpty
          ? const TakiEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Még nincs rendelésed',
              text: 'Indíts új keresést, és a rendeléseid itt jelennek meg.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: _orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final order = _orders[index];
                final status = order['status']?.toString();
                final editable = order['is_sos'] == true &&
                    (status == 'pending' ||
                        status == 'Expressz rendelés közzétéve');
                final end = WorkSchedule.end(order);
                final endText = end == null
                    ? ''
                    : '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        leading: Image.asset(
                      serviceImage(
                        (order['service'] ?? order['title'] ?? '').toString(),
                      ),
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                    ),
                        title: Text(
                      (order['service'] ?? order['title'] ?? 'Rendelés')
                          .toString(),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                        subtitle: Text(
                      '${order['date'] ?? ''} • ${order['time'] ?? ''}–$endText${order['area_sqm'] == null ? '' : ' • ${order['area_sqm']} m²'}\n${order['status'] ?? 'Függőben'}',
                    ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        order['status'] == 'Függőben'
                            ? '/offers'
                            : '/order/details',
                        arguments: {...order, 'view_role': 'customer'},
                      );
                          await _load();
                        },
                      ),
                      if (editable)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              key: ValueKey('edit-order-${order['request_id'] ?? order['id']}'),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Szerkesztés'),
                              onPressed: () async {
                                final changed = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    settings: RouteSettings(arguments: order),
                                    builder: (_) => const CustomerSearchScreen(startAsSos: true),
                                  ),
                                );
                                if (changed == true) await _load();
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    ),
  );
}
