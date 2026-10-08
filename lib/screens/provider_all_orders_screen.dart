import '../widgets/service_choice_grid.dart';
import '../widgets/taki_app_bar.dart';

import 'package:flutter/material.dart';

import '../services/local_marketplace_store.dart';
import '../theme.dart';
import '../widgets/branded_background.dart';
import '../utils/work_schedule.dart';

class ProviderAllOrdersScreen extends StatefulWidget {
  const ProviderAllOrdersScreen({super.key});
  @override
  State<ProviderAllOrdersScreen> createState() =>
      _ProviderAllOrdersScreenState();
}

class _ProviderAllOrdersScreenState extends State<ProviderAllOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  String _mode = 'all';
  bool _loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _mode = ModalRoute.of(context)?.settings.arguments?.toString() ?? 'all';
    _load();
  }

  Future<void> _load() async {
    final all = await LocalMarketplaceStore.providerOrders();
    _orders = all.where((order) {
      if (_mode == 'completed') return order['status'] == 'Teljesítve';
      if (_mode == 'reviews') {
        return (order['customer_feedback'] is Map &&
                WorkSchedule.reviewsVisible(order, DateTime.now())) ||
            order['rating'] is num;
      }
      return true;
    }).toList();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(
      title: Text(
        _mode == 'reviews'
            ? 'Értékeléseim'
            : (_mode == 'completed' ? 'Sikeres munkáim' : 'Munkáim'),
      ),
    ),
    body: BrandedBackground(
      child: _orders.isEmpty
          ? const TakiEmptyState(
              icon: Icons.assignment_outlined,
              title: 'Még nincs elfogadott munkád',
              text: 'Az elfogadott ajánlataid itt jelennek meg.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
              itemCount: _orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = _orders[index];
                final end = WorkSchedule.end(order);
                final endText = end == null
                    ? ''
                    : '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Image.asset(
                      serviceImage(
                        (order['service'] ?? order['title'] ?? '').toString(),
                      ),
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                    ),
                    title: Text(
                      order['service']?.toString() ?? 'Munka',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: _mode == 'reviews'
                        ? Text(
                            '${(order['customer_feedback'] as Map?)?['rating'] ?? order['rating']} / 5 ★\n${(order['customer_feedback'] as Map?)?['review'] ?? order['review'] ?? ''}',
                          )
                        : Text(
                            '${order['date'] ?? ''} • ${order['time'] ?? ''}–$endText${order['area_sqm'] == null ? '' : ' • ${order['area_sqm']} m²'}\n${order['status'] ?? 'Elfogadva'}',
                          ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        '/order/details',
                        arguments: {...order, 'view_role': 'provider'},
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
