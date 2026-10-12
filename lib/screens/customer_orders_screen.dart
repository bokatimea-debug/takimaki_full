import '../widgets/taki_status_tabs.dart';
import '../widgets/taki_screen_header.dart';
import '../widgets/service_choice_grid.dart';
import '../widgets/taki_app_bar.dart';

import 'package:flutter/material.dart';

import '../services/local_marketplace_store.dart';
import '../theme.dart';
import '../widgets/branded_background.dart';
import '../utils/work_schedule.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});
  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  int _selectedStatus = 0;
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
              itemCount:
                  _orders
                      .where((r) => TakiStatusTabs.shows(r, _selectedStatus))
                      .length +
                  1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TakiScreenHeader(
                        title: 'Megrendelések',
                        subtitle: 'Áttekintés és állapotok',
                        icon: Icons.receipt_long_outlined,
                      ),
                      const SizedBox(height: 6),
                      TakiStatusTabs(
                        selected: _selectedStatus,
                        onChanged: (value) =>
                            setState(() => _selectedStatus = value),
                      ),
                      if (!_orders.any(
                        (r) => TakiStatusTabs.shows(r, _selectedStatus),
                      ))
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Ebben az állapotban nincs megjeleníthető tétel.',
                          ),
                        ),
                    ],
                  );
                final itemIndex = index - 1;
                final order = _orders
                    .where((r) => TakiStatusTabs.shows(r, _selectedStatus))
                    .elementAt(itemIndex);
                final end = WorkSchedule.end(order);
                final endText = end == null
                    ? ''
                    : '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
                return TakiPanel(
                  color: itemIndex.isEven ? takiCardMint : takiCardYellow,
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Image.asset(
                      serviceImage(
                        (order['service'] ?? order['title'] ?? '').toString(),
                      ),
                      width: 32,
                      height: 32,
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
                );
              },
            ),
    ),
  );
}
