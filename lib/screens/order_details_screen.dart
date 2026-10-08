import '../utils/public_name.dart';
import '../widgets/taki_app_bar.dart';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../data/mock_data.dart';
import '../services/local_chat_store.dart';
import '../services/local_marketplace_store.dart';
import '../services/sanctions_store.dart';
import '../services/workflow_store.dart';
import '../utils/work_schedule.dart';
import 'chat_screens.dart';
import '../widgets/branded_background.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic> _order = {};
  bool _loaded = false;
  bool _busy = false;
  String get _role =>
      _order['view_role'] == 'provider' ? 'provider' : 'customer';
  Future<void> _reload() async {
    final data = await LocalMarketplaceStore.customerOrders();
    final current = data
        .where((w) => WorkSchedule.id(w) == _requestId)
        .firstOrNull;
    if (current != null && mounted)
      setState(() => _order = {...current, 'view_role': _role});
  }

  Future<void> _guard(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      await _reload();
    } on StateError catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reschedule() async {
    final now = DateTime.now();
    final currentStart = WorkSchedule.start(_order) ?? now;
    final currentEnd = WorkSchedule.end(_order) ??
        currentStart.add(const Duration(hours: 1));
    String hm(DateTime value) =>
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Időpont módosítása'),
        content: Text(
          'Jelenlegi időpont:\n${_order['date']} • ${hm(currentStart)}–${hm(currentEnd)}\n\nA másik fél értesítést kap a változásról.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Új időpont megadása'),
          ),
        ],
      ),
    );
    if (proceed != true || !mounted) return;
    final date = await showDatePicker(
      context: context,
      initialDate: currentStart.isBefore(now) ? now : currentStart,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentStart),
    );
    if (time == null || !mounted) return;
    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentEnd),
      helpText: 'Befejezési idő',
    );
    if (endTime == null) return;
    final startMinutes = time.hour * 60 + time.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    if (endMinutes <= startMinutes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A befejezésnek későbbinek kell lennie a kezdésnél.'),
          ),
        );
      }
      return;
    }
    await WorkflowStore.reschedule(
      _order,
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
      endMinutes - startMinutes,
      _role,
    );
    await _reload();
    await WorkflowStore.reconcileReminders(_order);
  }

  Future<void> _providerCancel() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Munka lemondása'),
        content: const Text(
          'A munka kikerül a naptárból, a megrendelő értesítést kap. A szolgáltatói lemondáshoz még nincs külön büntetés meghatározva. Biztosan lemondod?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Munka lemondása'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await _setStatus('Lemondva');
    await WorkflowStore.enqueue(
      _requestId,
      'customer',
      'Munka lemondva',
      '${_order['service']}',
    );
  }

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
    var fulfilled = true;
    final reviewController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Munka visszajelzése'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Teljesült a munka?'),
                value: fulfilled,
                onChanged: (v) => setDialogState(() => fulfilled = v),
              ),
              const Text(
                '3 napod van értékelni. A másik értékelése addig rejtett, amíg mindketten nem értékeltetek, vagy le nem jár a határidő.',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    onPressed: () => setDialogState(() => rating = index + 1),
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: takiOrange,
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
      await WorkflowStore.feedback(
        _order,
        _role,
        fulfilled,
        rating,
        reviewController.text.trim(),
      );
      await _reload();
    }
    reviewController.dispose();
  }

  Future<void> _complain() async {
    final controller = TextEditingController();
    var reason = 'Nem jelent meg';
    final submit = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, change) => AlertDialog(
          title: const Text('Probléma jelentése'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Belső hibajegy. Nem jelenik meg a nyilvános profilon. A jelentés önmagában nem jár büntetéssel.',
                ),
                DropdownButton<String>(
                  value: reason,
                  isExpanded: true,
                  items:
                      [
                            'Nem jelent meg',
                            'Hibás vagy hiányos teljesítés',
                            'Fizetési probléma',
                            'Nem elérhető partner',
                            'Egyéb',
                          ]
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                  onChanged: (v) => change(() => reason = v!),
                ),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Rövid leírás'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Mégse'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Beküldés'),
            ),
          ],
        ),
      ),
    );
    final text = controller.text;
    controller.dispose();
    if (submit == true) {
      await WorkflowStore.report(_order, _role, reason, text);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A belső hibajegyet rögzítettük.')),
        );
    }
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
    final count = await SanctionsStore.customerLateCancellationCount();
    if (!mounted) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rendelés lemondása'),
        content: Text(
          late
              ? '12 órán belül mondod le. Eddigi késői lemondásaid: $count. Ez lesz a ${count + 1}. alkalom. Három ilyen lemondás után 5 napos felfüggesztés jár. Biztosan lemondod?'
              : 'Több mint 12 órával a kezdés előtt mondod le; ezért nem jár késői lemondási büntetés. Biztosan lemondod?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rendelés lemondása'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    DateTime? suspendedUntil;
    if (late) {
      suspendedUntil = await SanctionsStore.recordCustomerLateCancellation();
    }
    await _setStatus('Lemondva');
    await WorkflowStore.enqueue(
      _requestId,
      'provider',
      'Munka lemondva',
      '${_order['service']}',
    );
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
        ? peerNameFor(_order, 'customer')
        : peerNameFor(_order, 'provider');
    final thread = MockData.ensureThread(
      requestId: _requestId,
      peerName: peerName,
      peerFirstName: peerName,
      peerRole: isProvider ? 'customer' : 'provider',
      peerId: _order[isProvider ? 'customer_id' : 'provider_id']?.toString(),
      viewRole: isProvider ? 'provider' : 'customer',
      peerPhotoB64:
          _order[isProvider ? 'customer_photo_b64' : 'provider_photo_b64']
              as String?,
      peerPhotoPath:
          _order[isProvider ? 'customer_photo_path' : 'provider_photo_path']
              as String?,
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
    final start = WorkSchedule.start(_order);
    final end = WorkSchedule.end(_order);
    String hhmm(DateTime? value) => value == null
        ? '–'
        : '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    final when = start == null
        ? (_order['when']?.toString() ?? 'Nincs megadva')
        : '${_order['date']} • ${hhmm(start)}–${hhmm(end)}';
    final isProvider = _order['view_role'] == 'provider';
    final status = _value('status', 'Függőben');
    final price = _value('price', _value('offered_price', ''));
    final canChat = const [
      'Elfogadva',
      'Folyamatban',
      'Teljesítve',
    ].contains(status);

    return Scaffold(
      appBar: TakiAppBar(title: const Text('Rendelés részletei')),
      body: SafeArea(
        top: false,
        child: BrandedBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              Text(
                _value('service', _value('title')),
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _Detail(
                icon: Icons.person_outline,
                label: 'Partner',
                value: isProvider
                    ? peerNameFor(_order, 'customer')
                    : peerNameFor(_order, 'provider'),
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
              if (_order['area_sqm'] != null)
                _Detail(
                  icon: Icons.square_foot_rounded,
                  label: 'Alapterület',
                  value: '${_order['area_sqm']} m²',
                ),
              if ((_order['service_options'] as List?)?.isNotEmpty == true)
                _Detail(
                  icon: Icons.checklist_rounded,
                  label: 'Kért szolgáltatások',
                  value: (_order['service_options'] as List).join(' • '),
                ),
              _Detail(
                icon: Icons.payments_outlined,
                label: 'Ár',
                value: price.isEmpty ? 'Nincs megadva' : '$price Ft',
              ),
              _Detail(
                icon: Icons.info_outline,
                label: 'Státusz',
                value: status,
              ),
              _Detail(
                icon: Icons.timelapse,
                label: 'Várható időtartam',
                value: '${WorkSchedule.minutes(_order)} perc',
              ),
              if (WorkSchedule.reviewsVisible(_order, DateTime.now()))
                for (final role in ['customer', 'provider'])
                  if (_order['${role}_feedback'] is Map)
                    _Detail(
                      icon: Icons.star_outline,
                      label: role == 'customer'
                          ? 'Megrendelő értékelése'
                          : 'Szolgáltató értékelése',
                      value:
                          '${_order['${role}_feedback']['rating']} / 5\n${_order['${role}_feedback']['review']}',
                    ),
              if (!WorkSchedule.reviewsVisible(_order, DateTime.now()) &&
                  _order['${_role}_feedback'] != null)
                const _Detail(
                  icon: Icons.lock_outline,
                  label: 'Értékelés',
                  value: 'Elmentve. A kölcsönös értékelésig vagy a 3 napos határidőig rejtett.',
                ),
              if (_order['schedule_history'] is List)
                for (final change in (_order['schedule_history'] as List))
                  _Detail(
                    icon: Icons.history,
                    label: 'Időpontváltozás',
                    value:
                        '${change['old_date']} ${change['old_time']} → ${change['date']} ${change['time']}',
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
              if (WorkSchedule.active(_order)) ...[
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _guard(_reschedule),
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text('Időpont módosítása'),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _guard(
                          isProvider ? _providerCancel : _customerCancel,
                        ),
                  child: const Text('Rendelés lemondása'),
                ),
              ],
              if (WorkSchedule.canReview(_order, _role, DateTime.now()))
                FilledButton.icon(
                  onPressed: _busy ? null : () => _guard(_rate),
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Teljesítés és értékelés'),
                ),
              if (canChat)
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _guard(_complain),
                  icon: const Icon(Icons.report_outlined),
                  label: const Text('Probléma jelentése'),
                ),
            ],
          ),
        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: takiFieldSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: takiTeal, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: takiMutedText,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: takiNavy,
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
