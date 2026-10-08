import '../widgets/service_choice_grid.dart';
import '../utils/public_name.dart';
import '../widgets/taki_app_bar.dart';

import 'package:flutter/material.dart';

import '../services/local_marketplace_store.dart';
import '../theme.dart';
import '../widgets/branded_background.dart';
import '../utils/work_schedule.dart';

class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({super.key});
  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen> {
  List<Map<String, dynamic>> _requests = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _requests = await LocalMarketplaceStore.providerRequests();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Új ajánlatkérések')),
    body: SafeArea(
      top: false,
      child: BrandedBackground(
        child: _requests.isEmpty
            ? const TakiEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'Most nincs új munka',
                text: 'Az új ajánlatkérések automatikusan itt jelennek meg.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(18),
                itemCount: _requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  final end = WorkSchedule.end(request);
                  final endText = end == null
                      ? ''
                      : '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
                  return TakiPanel(
                    color: index.isEven ? takiFieldSurface : takiYellowSoft,
                    padding: const EdgeInsets.all(16),
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                serviceImage(
                                  request['service']?.toString() ?? '',
                                ),
                                width: 42,
                                height: 42,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  request['service']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${peerNameFor(request, 'customer')} • ${request['address'] ?? ''}',
                          ),
                          Text(
                            '${request['date'] ?? ''} • ${request['time'] ?? ''}–$endText${request['area_sqm'] == null ? '' : ' • ${request['area_sqm']} m²'}',
                            style: const TextStyle(
                              color: takiMutedText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if ((request['service_options'] as List?)
                                  ?.isNotEmpty ==
                              true)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                (request['service_options'] as List).join(
                                  ' • ',
                                ),
                                style: const TextStyle(
                                  color: takiTealDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          const SizedBox(height: 14),
                          FilledButton(
                            onPressed: request['status'] == 'accepted'
                                ? null
                                : () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      '/provider/offer_reply',
                                      arguments: request,
                                    );
                                    if (result == true) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ajánlat elküldve.'),
                                        ),
                                      );
                                      await _load();
                                    }
                                  },
                            child: Text(
                              request['status'] == 'offered'
                                  ? 'Ajánlat módosítása'
                                  : 'Ajánlat küldése',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    ),
  );
}
