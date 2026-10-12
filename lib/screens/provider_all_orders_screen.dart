import '../widgets/taki_status_tabs.dart';
import '../widgets/taki_screen_header.dart';
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
  int _selectedStatus = 0;
  String _mode = 'all';
  bool _loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _mode = ModalRoute.of(context)?.settings.arguments?.toString() ?? 'all';
    if (_mode == 'completed') _selectedStatus = 2;
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
              itemCount:
                  _orders
                      .where(
                        (r) =>
                            (_mode == 'reviews' ||
                            TakiStatusTabs.shows(r, _selectedStatus)),
                      )
                      .length +
                  1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TakiScreenHeader(
                        title: 'Munkák',
                        subtitle: 'Elfogadott munkák és értékelések',
                        icon: Icons.assignment_outlined,
                      ),
                      const SizedBox(height: 6),
                      if (_mode != 'reviews')
                        TakiStatusTabs(
                          selected: _selectedStatus,
                          onChanged: (value) =>
                              setState(() => _selectedStatus = value),
                        ),
                      if (!_orders.any(
                        (r) =>
                            (_mode == 'reviews' ||
                            TakiStatusTabs.shows(r, _selectedStatus)),
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
                    .where(
                      (r) =>
                          (_mode == 'reviews' ||
                          TakiStatusTabs.shows(r, _selectedStatus)),
                    )
                    .elementAt(itemIndex);
                final end = WorkSchedule.end(order);
                final endText = end == null
                    ? ''
                    : '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
                return Card(
                  color: itemIndex.isEven ? takiCardMint : takiCardYellow,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
