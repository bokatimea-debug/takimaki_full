import '../utils/public_name.dart';
import '../widgets/taki_app_bar.dart';

import 'package:flutter/material.dart';

import '../services/local_marketplace_store.dart';
import '../theme.dart';
import '../widgets/branded_background.dart';
import '../utils/work_schedule.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});
  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  String _requestId = '';
  String _service = 'Szolgáltatás';
  List<Map<String, dynamic>> _offers = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestId.isNotEmpty) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _requestId = args['request_id']?.toString() ?? '';
      _service = args['service']?.toString() ?? _service;
    }
    _load();
  }

  Future<void> _load() async {
    if (_requestId.isNotEmpty) {
      _offers = await LocalMarketplaceStore.offersFor(_requestId);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _accept(Map<String, dynamic> offer) async {
    try {
      await LocalMarketplaceStore.acceptOffer(offer);
    } on StateError catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message.toString())));
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: takiTeal, size: 52),
        title: const Text('Ajánlat elfogadva'),
        content: Text(
          '${peerNameFor(offer, 'provider')} ajánlatát elfogadtad. Most már üzenetet is küldhettek egymásnak.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Rendben'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/customer/orders',
      (route) => route.settings.name == '/customer/profile' || route.isFirst,
    );
  }

  Future<void> _reject(Map<String, dynamic> offer) async {
    await LocalMarketplaceStore.rejectOffer(offer['id'].toString());
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Beérkezett ajánlatok')),
    body: BrandedBackground(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _offers.where((o) => o['status'] == 'pending').isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded, size: 72, color: takiTeal),
                    SizedBox(height: 18),
                    Text(
                      'Még nincs elérhető szolgáltató',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: takiTealDark,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Az új ajánlatok automatikusan itt jelennek meg.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              children: [
                SectionBadge(icon: Icons.local_offer_outlined, text: _service),
                if (_offers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TakiPanel(
                    color: takiMint,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, color: takiTealDark),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _offerSchedule(_offers.first),
                            style: const TextStyle(
                              color: takiNavy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ..._offers
                    .where((o) => o['status'] == 'pending')
                    .map(
                      (offer) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: takiMint,
                                    child: Text(
                                      peerNameFor(offer, 'provider')[0],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: takiTealDark,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          peerNameFor(offer, 'provider'),
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          '★ ${offer['provider_rating'] ?? 'Új'}  •  ${offer['provider_success_count'] ?? 0} sikeres munka',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${offer['price']} Ft',
                                style: const TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                  color: takiOrange,
                                ),
                              ),
                              if ((offer['note'] ?? '').toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(offer['note'].toString()),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _reject(offer),
                                      child: const Text('Elutasítás'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () => _accept(offer),
                                      child: const Text('Elfogadás'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
    ),
  );

  String _offerSchedule(Map<String, dynamic> offer) {
    final end = WorkSchedule.end(offer);
    final endText = end == null
        ? '–'
        : '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '${offer['date'] ?? ''} • ${offer['time'] ?? ''}–$endText${offer['area_sqm'] == null ? '' : ' • ${offer['area_sqm']} m²'}';
  }
}
