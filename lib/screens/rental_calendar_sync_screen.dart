import 'package:flutter/material.dart';

import '../services/local_marketplace_store.dart';
import '../services/rental_cleaning_drafts.dart';
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
  List<Map<String, dynamic>> _drafts = [];
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final feeds = await RentalCalendarSync.feeds(); final events = await RentalCalendarSync.events(); final drafts = await RentalCleaningDrafts.all(); if (mounted) setState(() { _feeds = feeds; _events = events; _drafts = drafts; }); }

  Future<void> _sendDraft(Map<String, dynamic> draft) async {
    final address = TextEditingController();
    final note = TextEditingController(text: '${draft['booking_title']} • ${draft['provider']} naptárból létrehozott vendégváltási takarítás.');
    final suggested = DateTime.tryParse(draft['suggested_at']?.toString() ?? '') ?? DateTime.now();
    var time = TimeOfDay.fromDateTime(suggested);
    final approved = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
      title: const Text('Piszkozat ellenőrzése'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('${draft['booking_title']}\nJavasolt nap: ${suggested.year}.${suggested.month.toString().padLeft(2, '0')}.${suggested.day.toString().padLeft(2, '0')}.', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        TextField(controller: address, decoration: const InputDecoration(labelText: 'Apartman címe *')),
        const SizedBox(height: 8),
        ListTile(contentPadding: EdgeInsets.zero, title: const Text('Javasolt kezdés'), subtitle: Text(time.format(context)), trailing: const Icon(Icons.schedule_rounded), onTap: () async { final chosen = await showTimePicker(context: context, initialTime: time); if (chosen != null) setLocal(() => time = chosen); }),
        TextField(controller: note, maxLines: 3, decoration: const InputDecoration(labelText: 'Megjegyzés')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Mégse')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Ajánlatkérés kiküldése'))],
    )));
    if (approved != true || address.text.trim().isEmpty) { address.dispose(); note.dispose(); return; }
    final when = DateTime(suggested.year, suggested.month, suggested.day, time.hour, time.minute);
    try {
      final requestId = await LocalMarketplaceStore.createRequest(service: 'Apartmantakarítás', address: address.text.trim(), dateTime: when, note: note.text.trim(), laundryAndIroning: false, durationMinutes: draft['duration_minutes'] as int? ?? 120);
      await RentalCleaningDrafts.markSent(draft['id'].toString(), requestId);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajánlatkérés kiküldve.')));
    } on StateError catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message.toString()))); }
    address.dispose(); note.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Foglalási fiókok')),
    body: BrandedBackground(child: SafeArea(top: false, child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('A fiók-összekötés opcionális. Összekapcsolás után a Takimaki a kijelentkezésekből takarítási piszkozatot készít; jelszót nem kér és nem tárol.', style: TextStyle(color: takiMutedText)),
        const SizedBox(height: 12),
        for (final provider in const ['Airbnb', 'Booking.com']) ...[
          TakiPanel(child: ListTile(leading: const Icon(Icons.calendar_month_rounded, color: takiTeal), title: Text(provider), subtitle: Text(_feeds.any((f) => f['provider'] == provider) ? 'Korábbi import található' : 'Nincs kapcsolva'), trailing: const Chip(label: Text('Hamarosan')))),
          const SizedBox(height: 8),
        ],
        const TakiPanel(
          color: takiYellowSoft,
          padding: EdgeInsets.all(12),
          child: Text('A közvetlen Airbnb- és Booking-kapcsolat csak a Takimaki hivatalos partneri API-hozzáférésének beállítása után indítható. Addig nem kérünk iCal-linket és nem állítjuk késznek az automatikus importot.'),
        ),
        if (_drafts.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text('Automatikus takarítási piszkozatok', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: takiNavy)),
          const SizedBox(height: 4),
          const Text('A foglalásból készülnek. Csak jóváhagyás után mennek ki ajánlatkérésként.', style: TextStyle(color: takiMutedText)),
          const SizedBox(height: 8),
          for (final draft in _drafts.where((item) => item['status'] == 'draft')) TakiPanel(child: ListTile(
            leading: const Icon(Icons.cleaning_services_rounded, color: takiTeal),
            title: Text(draft['booking_title']?.toString() ?? 'Foglalás'),
            subtitle: Text('${draft['provider']} • ${draft['suggested_at']?.toString().split('T').first ?? ''} • Apartmantakarítás'),
            trailing: FilledButton(onPressed: () => _sendDraft(draft), child: const Text('Ellenőrzés')),
          )),
        ],
        if (_events.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('Beolvasott foglalások (${_events.length})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: takiNavy)),
          for (final event in _events.take(20)) ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event_busy_outlined, color: takiOrange), title: Text(event['title'] ?? 'Foglalt'), subtitle: Text('${event['provider']} • ${event['start']} – ${event['end'] ?? ''}')),
        ],
      ],
    ))),
  );
}
