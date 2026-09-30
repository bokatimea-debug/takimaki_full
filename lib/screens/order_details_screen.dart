import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/local_chat_store.dart';
import '../services/local_marketplace_store.dart';
import '../services/sanctions_store.dart';
import 'chat_screens.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic> _order = {};
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) _order = Map<String, dynamic>.from(args);
  }

  String _value(String key, [String fallback = 'Nincs megadva']) {
    final result = _order[key]?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  String get _requestId =>
      (_order['request_id'] ?? _order['id'] ?? '').toString();

  Future<void> _setStatus(String status) async {
    if (_requestId.isEmpty) return;
    await LocalMarketplaceStore.updateOrderStatus(_requestId, status);
    if (!mounted) return;
    setState(() => _order['status'] = status);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Új státusz: $status')));
  }

  Future<void> _rate() async {
    var rating = 5;
    final reviewController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Szolgáltató értékelése'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    onPressed: () => setDialogState(() => rating = index + 1),
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFF8C42),
                    ),
                  ),
                ),
              ),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Szöveges értékelés (opcionális)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Mégse'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Értékelés mentése'),
            ),
          ],
        ),
      ),
    );
    if (saved == true && _requestId.isNotEmpty) {
      await LocalMarketplaceStore.rateOrder(
        requestId: _requestId,
        rating: rating,
        review: reviewController.text.trim(),
      );
      if (rating <= 2) {
        await SanctionsStore.addProviderNegativePoint();
      }
      if (mounted) {
        setState(() {
          _order['rating'] = rating;
          _order['review'] = reviewController.text.trim();
        });
      }
    }
    reviewController.dispose();
  }

  Future<void> _reportNoShow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No-show jelentése'),
        content: const Text(
          'Biztosan jelented, hogy a szolgáltató nem jelent meg?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Jelentés'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final recorded = await LocalMarketplaceStore.recordOrderAction(
      requestId: _requestId,
      key: 'no_show_reported',
      value: DateTime.now().toIso8601String(),
    );
    if (!recorded) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ezt a no-show esetet már jelentetted.')),
      );
      return;
    }
    final suspendedUntil = await SanctionsStore.recordProviderNoShow();
    if (_requestId.isNotEmpty) {
      await LocalMarketplaceStore.updateOrderStatus(_requestId, 'No-show');
    }
    if (!mounted) return;
    setState(() => _order['status'] = 'No-show');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          suspendedUntil == null
              ? 'A no-show jelentést rögzítettük.'
              : 'A szolgáltatói fiókot 14 napra felfüggesztettük.',
        ),
      ),
    );
  }

  Future<void> _complain() async {
    final controller = TextEditingController();
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Panasz küldése'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Panasz leírása'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Küldés'),
          ),
        ],
      ),
    );
    final text = controller.text.trim();
    controller.dispose();
    if (submit != true || text.isEmpty) return;
    final recorded = await LocalMarketplaceStore.recordOrderAction(
      requestId: _requestId,
      key: 'complaint',
      value: text,
    );
    if (!recorded) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ehhez a rendeléshez már küldtél panaszt.'),
        ),
      );
      return;
    }
    final suspendedUntil = await SanctionsStore.addProviderNegativePoint();
    if (!mounted) return;
    setState(() => _order['complaint'] = text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          suspendedUntil == null
              ? 'A panaszt rögzítettük.'
              : 'A szolgáltatói fiókot 14 napra felfüggesztettük.',
        ),
      ),
    );
  }

  Future<void> _customerCancel() async {
    final date = _order['date']?.toString() ?? '';
    final time = _order['time']?.toString() ?? '';
    final workAt = DateTime.tryParse('${date}T$time:00');
    if (workAt != null && !DateTime.now().isBefore(workAt)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A munka időpontja után a rendelés már nem mondható le.',
          ),
        ),
      );
      return;
    }
    final late =
        workAt != null &&
        workAt.difference(DateTime.now()) <= const Duration(hours: 12);
    DateTime? suspendedUntil;
    if (late) {
      suspendedUntil = await SanctionsStore.recordCustomerLateCancellation();
    }
    await _setStatus('Lemondva');
    if (!mounted || suspendedUntil == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Három késői lemondás miatt a fiók 5 napra felfüggesztésre került.',
        ),
      ),
    );
  }

  Future<void> _openChat(bool isProvider) async {
    if (_requestId.isEmpty) return;
    await LocalChatStore.load();
    final peerName = isProvider
        ? _value('customer', 'Megrendelő')
        : _value('provider', _value('provider_name', 'Szolgáltató'));
    final thread = MockData.ensureThread(
      requestId: _requestId,
      peerName: peerName,
    );
    await LocalChatStore.save();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatThreadScreen(threadId: thread.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final when =
        _order['when']?.toString() ??
        [_order['date'], _order['time']]
            .where((item) => item != null && item.toString().isNotEmpty)
            .join(' • ');
    final isProvider = _order['view_role'] == 'provider';
    final status = _value('status', 'Függőben');
    final price = _value('price', _value('offered_price', ''));
    final canChat = const [
      'Elfogadva',
      'Folyamatban',
      'Teljesítve',
    ].contains(status);
    final scheduledAt = DateTime.tryParse(
      '${_order['date'] ?? ''}T${_order['time'] ?? ''}:00',
    );
    final workTimePassed =
        scheduledAt != null && DateTime.now().isAfter(scheduledAt);

    return Scaffold(
      appBar: AppBar(title: const Text('Rendelés részletei')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _value('service', _value('title')),
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _Detail(
            icon: Icons.person_outline,
            label: 'Partner',
            value: isProvider
                ? _value('customer', 'Megrendelő')
                : _value('provider', _value('provider_name', 'Szolgáltató')),
          ),
          _Detail(
            icon: Icons.location_on_outlined,
            label: 'Helyszín',
            value: _value('address'),
          ),
          _Detail(
            icon: Icons.calendar_today_outlined,
            label: 'Időpont',
            value: when.isEmpty ? 'Nincs megadva' : when,
          ),
          _Detail(
            icon: Icons.payments_outlined,
            label: 'Ár',
            value: price.isEmpty ? 'Nincs megadva' : '$price Ft',
          ),
          _Detail(icon: Icons.info_outline, label: 'Státusz', value: status),
          if ((_order['rating'] as num?) != null)
            _Detail(
              icon: Icons.star_outline,
              label: 'Értékelés',
              value:
                  '${_order['rating']} / 5${_value('review', '').isEmpty ? '' : '\n${_order['review']}'}',
            ),
          if (_value('note', '').isNotEmpty)
            _Detail(
              icon: Icons.notes,
              label: 'Megjegyzés',
              value: _value('note'),
            ),
          if (_value('complaint', '').isNotEmpty)
            _Detail(
              icon: Icons.report_outlined,
              label: 'Beküldött panasz',
              value: _value('complaint'),
            ),
          if (_order['laundry_and_ironing'] == true)
            const _Detail(
              icon: Icons.local_laundry_service_outlined,
              label: 'Apartmantakarítás',
              value: 'Mosással és vasalással',
            ),
          const SizedBox(height: 8),
          if (canChat)
            OutlinedButton.icon(
              onPressed: () => _openChat(isProvider),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Kapcsolódó chat'),
            ),
          if (isProvider && status == 'Elfogadva') ...[
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => _setStatus('Folyamatban'),
              child: const Text('Munka megkezdése'),
            ),
          ],
          if (isProvider && status == 'Folyamatban') ...[
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => _setStatus('Teljesítve'),
              child: const Text('Munka teljesítve'),
            ),
          ],
          if (isProvider && !const ['Teljesítve', 'Lemondva'].contains(status))
            TextButton(
              onPressed: () => _setStatus('Lemondva'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Rendelés lemondása'),
            ),
          if (!isProvider && status == 'Teljesítve' && _order['rating'] == null)
            FilledButton.icon(
              onPressed: _rate,
              icon: const Icon(Icons.star_outline),
              label: const Text('Szolgáltató értékelése'),
            ),
          if (!isProvider &&
              const ['Elfogadva', 'Folyamatban'].contains(status)) ...[
            const SizedBox(height: 8),
            if (workTimePassed)
              OutlinedButton.icon(
                onPressed: _reportNoShow,
                icon: const Icon(Icons.person_off_outlined),
                label: const Text('No-show jelentése'),
              ),
            if (_value('complaint', '').isEmpty)
              TextButton(
                onPressed: _complain,
                child: const Text('Panasz küldése'),
              ),
            TextButton(
              onPressed: _customerCancel,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Rendelés lemondása'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
      ),
    );
  }
}
