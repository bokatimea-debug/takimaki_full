import '../widgets/service_choice_grid.dart';
import '../utils/public_name.dart';
import '../widgets/taki_app_bar.dart';

import 'package:flutter/material.dart';

import '../services/local_marketplace_store.dart';
import '../services/sanctions_store.dart';
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
    _requests.sort((a, b) {
      final aSos = a['is_sos'] == true;
      final bSos = b['is_sos'] == true;
      if (aSos != bSos) return aSos ? -1 : 1;
      return (b['created_at']?.toString() ?? '').compareTo(
        a['created_at']?.toString() ?? '',
      );
    });
    if (mounted) setState(() {});
  }

  Future<void> _acceptSos(Map<String, dynamic> request) async {
    final suspendedUntil = await SanctionsStore.providerSosSuspendedUntil();
    if (suspendedUntil != null && DateTime.now().isBefore(suspendedUntil)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        'Az SOS-hozzáférésed ${suspendedUntil.toLocal().toString().split(' ').first}-ig fel van függesztve.',
      )));
      return;
    }
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SOS-munka elfogadása'),
        content: const Text(
          'Csak akkor fogadd el, ha biztosan megérkezel a megadott időablakon belül. SOS-munkánál történt meg nem jelenés bejelentése után az SOS-előfizetésed 3 hónapra felfüggesztésre kerül.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Mégse')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Biztosan vállalom')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await LocalMarketplaceStore.acceptSosRequest(request);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('SOS-munka elfogadva. A megrendelő értesítést kapott.'),
      ));
      await _load();
    } on StateError catch (error) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message.toString())));
    }
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
                  final isSos = request['is_sos'] == true;
                  return TakiPanel(
                    color: isSos ? const Color(0xFFFFE2D6) : index.isEven ? takiFieldSurface : takiYellowSoft,
                    padding: const EdgeInsets.all(16),
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isSos) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: takiOrange, borderRadius: BorderRadius.circular(20)),
                              child: Text('⚡ SOS • ${request['sos_arrival_within_hours']} órán belül', style: const TextStyle(fontWeight: FontWeight.w900, color: takiTealDark)),
                            ),
                            const SizedBox(height: 10),
                          ],
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
                          if (isSos)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                'Kiírt munkadíj: ${request['listed_price'] ?? request['price']} Ft',
                                style: const TextStyle(
                                  color: takiTealDark,
                                  fontWeight: FontWeight.w900,
                                ),
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
                            style: isSos ? FilledButton.styleFrom(backgroundColor: takiTeal, foregroundColor: Colors.white) : null,
                            onPressed: request['status'] == 'accepted'
                                ? null
                                : isSos
                                    ? () => _acceptSos(request)
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
                              isSos
                                  ? 'Részletek és elfogadás'
                                  : request['status'] == 'offered'
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
