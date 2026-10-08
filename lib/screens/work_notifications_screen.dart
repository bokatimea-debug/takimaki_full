import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/local_marketplace_store.dart';
import '../services/workflow_store.dart';
import '../utils/work_schedule.dart';
import '../widgets/taki_app_bar.dart';
import '../widgets/branded_background.dart';
import '../theme.dart';

class WorkNotificationsScreen extends StatefulWidget {
  const WorkNotificationsScreen({super.key});
  @override
  State<WorkNotificationsScreen> createState() =>
      _WorkNotificationsScreenState();
}

class _WorkNotificationsScreenState extends State<WorkNotificationsScreen> {
  List<Map<String, dynamic>> _notices = [];
  String _role = 'customer';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('active_role') ?? 'customer';
    final notices = (await WorkflowStore.visibleNotifications(role))
          ..sort((a, b) => b['at'].toString().compareTo(a['at'].toString()));
    if (mounted)
      setState(() {
        _role = role;
        _notices = notices;
      });
  }

  Future<void> _open(Map<String, dynamic> notice) async {
    await WorkflowStore.markNotificationRead(_role, notice);
    final works = _role == 'provider'
        ? await LocalMarketplaceStore.providerOrders()
        : await LocalMarketplaceStore.customerOrders();
    final work = works
        .where((w) => WorkSchedule.id(w) == notice['request_id'])
        .firstOrNull;
    if (!mounted) return;
    if (work != null) {
      await Navigator.pushNamed(
        context,
        '/order/details',
        arguments: {...work, 'view_role': _role},
      );
    } else {
      await Navigator.pushNamed(
        context,
        _role == 'provider' ? '/provider/requests' : '/offers',
        arguments: {'request_id': notice['request_id']},
      );
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Munkaértesítések')),
    body: BrandedBackground(
      child: SafeArea(
        top: false,
        child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TakiPanel(
              color: takiMint,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    size: 30,
                    color: takiTealDark,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _notices.where((notice) => notice['read'] != true).isEmpty
                          ? 'Minden értesítést elolvastál'
                          : '${_notices.where((notice) => notice['read'] != true).length} új értesítésed van',
                      style: const TextStyle(
                        color: takiNavy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_notices.isEmpty)
              const TakiEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'Még nincs értesítésed',
                text: 'Az ajánlatok, munkák és időpontváltozások itt jelennek meg.',
              ),
            for (var index = 0; index < _notices.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TakiPanel(
                  color: _notices[index]['read'] == true
                      ? takiFieldSurface
                      : (index.isEven ? takiYellowSoft : takiMint),
                  padding: EdgeInsets.zero,
                  child: ListTile(
                  leading: Icon(
                    _notices[index]['read'] == true
                        ? Icons.notifications_outlined
                        : Icons.notifications_active_rounded,
                    color: _notices[index]['read'] == true
                        ? takiMutedText
                        : Colors.red,
                  ),
                  title: Text(
                    _notices[index]['title'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(_notices[index]['body'].toString()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _open(_notices[index]),
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    ),
  );
}
