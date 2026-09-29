import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/local_marketplace_store.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<Map<String, dynamic>> _items = [];
  String? _requestId;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) _requestId = args['request_id']?.toString();
    _load();
  }

  Future<void> _load() async {
    if (_requestId == null) {
      _items = MockData.offers
          .map(
            (offer) => <String, dynamic>{
              'id': offer.id,
              'request_id': 'demo',
              'service': offer.service,
              'provider_name': offer.providerName,
              'district': offer.district,
              'date': dt(context, offer.dateTime),
              'time': '',
              'price': offer.priceFt,
              'status': 'pending',
            },
          )
          .toList();
    } else {
      _items = await LocalMarketplaceStore.offersFor(_requestId!);
      _items = _items
          .where(
            (offer) =>
                offer['status'] == 'pending' &&
                !LocalMarketplaceStore.isResponseExpired(offer),
          )
          .toList();
    }
    if (mounted) setState(() {});
  }

  Future<void> _accept(Map<String, dynamic> offer) async {
    if (_requestId != null) await LocalMarketplaceStore.acceptOffer(offer);
    final providerName = offer['provider_name']?.toString() ?? 'Szolgáltató';
    MockData.ensureThread(
      requestId: (offer['request_id'] ?? offer['id']).toString(),
      peerName: providerName,
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFF0FA3A9),
          size: 42,
        ),
        title: const Text('Ajánlat elfogadva'),
        content: Text(
          '$providerName ajánlatát elfogadtad. A rendelés megjelent a Rendeléseim között.',
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
    Navigator.pushReplacementNamed(context, '/customer/orders');
  }

  Future<void> _reject(Map<String, dynamic> offer) async {
    await LocalMarketplaceStore.rejectOffer(offer['id'].toString());
    if (!mounted) return;
    setState(() => _items.removeWhere((item) => item['id'] == offer['id']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beérkezett ajánlatok')),
      body: _items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A kérés elküldve',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Itt jelennek meg a szolgáltatók ajánlatai.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final offer = _items[index];
                  final price = int.tryParse(offer['price'].toString()) ?? 0;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.person_outline),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offer['provider_name']?.toString() ??
                                          'Szolgáltató',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(offer['service']?.toString() ?? ''),
                                    if (offer['provider_rating'] is num)
                                      Text(
                                        '★ ${(offer['provider_rating'] as num).toStringAsFixed(1)} • ${offer['provider_success_count'] ?? 0} sikeres munka',
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    else
                                      Text(
                                        '${offer['provider_success_count'] ?? 0} sikeres munka',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                ft(price),
                                style: const TextStyle(
                                  color: Color(0xFFFF8C42),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${offer['date'] ?? ''} ${offer['time'] ?? ''} • Budapest ${offer['district'] ?? ''}. kerület',
                          ),
                          if ((offer['note']?.toString() ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(offer['note'].toString()),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _reject(offer),
                                  child: const Text('Elutasítás'),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                  );
                },
              ),
            ),
    );
  }
}
