import '../utils/public_name.dart';
import '../widgets/taki_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/local_marketplace_store.dart';
import '../theme.dart';
import '../utils/work_schedule.dart';
import '../widgets/branded_background.dart';

class ProviderOfferReplyScreen extends StatefulWidget {
  const ProviderOfferReplyScreen({super.key});
  @override
  State<ProviderOfferReplyScreen> createState() =>
      _ProviderOfferReplyScreenState();
}

class _ProviderOfferReplyScreenState extends State<ProviderOfferReplyScreen> {
  final _price = TextEditingController();
  final _note = TextEditingController();
  Map<String, dynamic> _request = {};
  bool _sending = false;
  bool _existingLoaded = false;
  bool _isEditing = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_request.isNotEmpty) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _request = Map<String, dynamic>.from(args);
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    if (_existingLoaded) return;
    _existingLoaded = true;
    final existing = await LocalMarketplaceStore.ownOfferFor(_request);
    if (existing == null || !mounted) return;
    _price.text = existing['price']?.toString() ?? '';
    _note.text = existing['note']?.toString() ?? '';
    setState(() => _isEditing = true);
  }

  @override
  void dispose() {
    _price.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final amount = int.tryParse(_price.text.replaceAll(' ', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Adj meg érvényes árat.')));
      return;
    }
    setState(() => _sending = true);
    try {
      await LocalMarketplaceStore.sendOffer(
        request: _request,
        price: amount,
        note: _note.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Az ajánlatot nem sikerült menteni. Próbáld újra.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = WorkSchedule.start(_request);
    final end = WorkSchedule.end(_request);
    String hhmm(DateTime? value) => value == null
        ? '–'
        : '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return Scaffold(
    appBar: TakiAppBar(
      title: Text(_isEditing ? 'Ajánlat módosítása' : 'Ajánlat küldése'),
    ),
    body: SafeArea(
      top: false,
      child: BrandedBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SectionBadge(
              icon: Icons.request_quote,
              text: _request['service']?.toString() ?? 'Ajánlatkérés',
            ),
            const SizedBox(height: 18),
            TakiPanel(
              color: takiFieldSurface,
              padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peerNameFor(_request, 'customer'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 12),
                    _InfoLine(
                      icon: Icons.location_on_outlined,
                      text: _request['address']?.toString() ?? '',
                    ),
                    _InfoLine(
                      icon: Icons.schedule_rounded,
                      text:
                          '${_request['date'] ?? ''}  ${hhmm(start)}–${hhmm(end)}',
                    ),
                    if (_request['area_sqm'] != null)
                      _InfoLine(
                        icon: Icons.square_foot_rounded,
                        text: '${_request['area_sqm']} m²',
                      ),
                    if ((_request['service_options'] as List?)?.isNotEmpty == true)
                      _InfoLine(
                        icon: Icons.checklist_rounded,
                        text: (_request['service_options'] as List).join(' • '),
                      ),
                    if ((_request['note'] ?? '').toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(_request['note'].toString()),
                      ),
                  ],
                ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Ajánlott ár (Ft)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Üzenet a megrendelőnek (opcionális)',
                prefixIcon: Icon(Icons.chat_bubble_outline),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _sending ? null : _send,
              child: Text(
                _sending
                    ? 'Mentés…'
                    : (_isEditing
                          ? 'Módosítás mentése'
                          : 'Ajánlat elküldése'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoLine({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      children: [
        Icon(icon, size: 19, color: takiTeal),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
