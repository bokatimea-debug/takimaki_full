import 'dart:io';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/local_chat_store.dart';
import '../services/local_marketplace_store.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<Map<String, dynamic>> _items = [];
  String? _requestId;
  Map<dynamic, dynamic> _searchArgs = const {};
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _searchArgs = args;
      _requestId = args['request_id']?.toString();
    }
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
      if (_items.isEmpty) {
        _items = _demoOffersForRequest();
      }
    }
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> _demoOffersForRequest() {
    final service = _searchArgs['service']?.toString() ?? 'Szolgáltatás';
    final district = _searchArgs['district']?.toString() ?? 'XIII';
    final selectedDate = _searchArgs['date'];
    final selectedTime = _searchArgs['time'];
    final date = selectedDate is DateTime
        ? '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}.'
        : '';
    final time = selectedTime is TimeOfDay
        ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
        : '';
    final providers = [
      ('Kiss Anna', 4.9, 38, 14500, 'Megbízható, pontos szolgáltató.'),
      ('Tiszta Otthon', 4.8, 61, 15900, 'Többéves tapasztalattal vállalom.'),
      ('Nagy Petra', 4.7, 24, 13500, 'A megadott időpont megfelelő.'),
    ];
    return providers.indexed.map((entry) {
      final i = entry.$1;
      final provider = entry.$2;
      return <String, dynamic>{
        'id': 'demo_${_requestId}_$i',
        'request_id': _requestId,
        'service': service,
        'provider_name': provider.$1,
        'provider_rating': provider.$2,
        'provider_rating_count': provider.$3,
        'provider_success_count': provider.$3,
        'district': district,
        'date': date,
        'time': time,
        'price': provider.$4,
        'note': provider.$5,
        'status': 'pending',
      };
    }).toList();
  }

  Future<void> _accept(Map<String, dynamic> offer) async {
    if (_requestId != null) await LocalMarketplaceStore.acceptOffer(offer);
    final providerName = offer['provider_name']?.toString() ?? 'Szolgáltató';
    await LocalChatStore.load();
    MockData.ensureThread(
      requestId: (offer['request_id'] ?? offer['id']).toString(),
      peerName: providerName,
    );
    await LocalChatStore.save();
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

  ImageProvider? _photo(Map<String, dynamic> offer) {
    final path = offer['provider_photo_path']?.toString() ?? '';
    if (path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? FileImage(file) : null;
  }

  Future<void> _showDetails(Map<String, dynamic> offer) async {
    final price = int.tryParse(offer['price'].toString()) ?? 0;
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundImage: _photo(offer),
                  child: _photo(offer) == null
                      ? const Icon(Icons.person_outline, size: 42)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                offer['provider_name']?.toString() ?? 'Szolgáltató',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if ((offer['provider_bio']?.toString() ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  offer['provider_bio'].toString(),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 14),
              Text(
                offer['provider_rating'] is num
                    ? '★ ${(offer['provider_rating'] as num).toStringAsFixed(1)} (${offer['provider_rating_count'] ?? 0} értékelés) • ${offer['provider_success_count'] ?? 0} sikeres munka'
                    : '${offer['provider_success_count'] ?? 0} sikeres munka • Az értékelés 5 munka után látható',
                textAlign: TextAlign.center,
              ),
              const Divider(height: 28),
              Text(
                offer['service']?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text('${offer['date'] ?? ''} ${offer['time'] ?? ''}'),
              Text('Budapest ${offer['district'] ?? ''}. kerület'),
              const SizedBox(height: 10),
              Text(
                ft(price),
                style: const TextStyle(
                  color: Color(0xFFFF8C42),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if ((offer['note']?.toString() ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(offer['note'].toString()),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, 'reject'),
                      child: const Text('Elutasítás'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, 'accept'),
                      child: const Text('Elfogadás'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'accept') await _accept(offer);
    if (action == 'reject') await _reject(offer);
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _showDetails(offer),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                            if ((offer['note']?.toString() ?? '')
                                .isNotEmpty) ...[
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
                    ),
                  );
                },
              ),
            ),
    );
  }
}
