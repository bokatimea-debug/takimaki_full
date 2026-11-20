import 'package:flutter/material.dart';

import '../services/rental_calendar_sync.dart';
import '../theme.dart';
import '../widgets/branded_background.dart';
import '../widgets/taki_app_bar.dart';

class RentalCalendarSyncScreen extends StatefulWidget {
  const RentalCalendarSyncScreen({super.key});
  @override
  State<RentalCalendarSyncScreen> createState() => _RentalCalendarSyncScreenState();
}

class _RentalCalendarSyncScreenState extends State<RentalCalendarSyncScreen> {
  List<Map<String, String>> _feeds = [];
  List<Map<String, String>> _events = [];
  bool _busy = false;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final feeds = await RentalCalendarSync.feeds(); final events = await RentalCalendarSync.events(); if (mounted) setState(() { _feeds = feeds; _events = events; }); }
  Future<void> _add(String provider) async {
    final input = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: Text('$provider iCal-link'), content: TextField(controller: input, keyboardType: TextInputType.url, decoration: const InputDecoration(hintText: 'https://... .ics')), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Mégse')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Mentés'))]));
    if (ok == true && input.text.trim().isNotEmpty) { await RentalCalendarSync.saveFeed(provider, input.text); await _load(); }
    input.dispose();
  }
  Future<void> _refresh() async { setState(() => _busy = true); try { final events = await RentalCalendarSync.refresh(); if (mounted) { setState(() => _events = events); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${events.length} foglalás frissítve.'))); } } on StateError catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString()))); } finally { if (mounted) setState(() => _busy = false); } }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Airbnb és Booking naptár')),
    body: BrandedBackground(child: SafeArea(top: false, child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Add meg az Airbnb és Booking.com által kiadott privát iCal/ICS linket. A foglalások blokkolják az érintett időpontokat; jelszót nem tárolunk.', style: TextStyle(color: takiMutedText)),
        const SizedBox(height: 12),
        for (final provider in const ['Airbnb', 'Booking.com']) ...[
          TakiPanel(child: ListTile(leading: const Icon(Icons.calendar_month_rounded, color: takiTeal), title: Text(provider), subtitle: Text(_feeds.any((f) => f['provider'] == provider) ? 'Kapcsolva' : 'Nincs kapcsolva'), trailing: IconButton(icon: const Icon(Icons.link_rounded), onPressed: () => _add(provider)))),
          const SizedBox(height: 8),
        ],
        FilledButton.icon(onPressed: _busy || _feeds.isEmpty ? null : _refresh, icon: const Icon(Icons.sync_rounded), label: Text(_busy ? 'Frissítés…' : 'Naptárak frissítése')),
        if (_events.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('Beolvasott foglalások (${_events.length})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: takiNavy)),
          for (final event in _events.take(20)) ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event_busy_outlined, color: takiOrange), title: Text(event['title'] ?? 'Foglalt'), subtitle: Text('${event['provider']} • ${event['start']} – ${event['end'] ?? ''}')),
        ],
      ],
    ))),
  );
}
