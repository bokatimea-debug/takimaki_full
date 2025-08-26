import 'package:flutter/material.dart';
import '../models/sanctions.dart';
import '../services/notifications.dart';

class ModerationDemoScreen extends StatefulWidget {
  const ModerationDemoScreen({super.key});

  @override
  State<ModerationDemoScreen> createState() => _ModerationDemoScreenState();
}

class _ModerationDemoScreenState extends State<ModerationDemoScreen> {
  final engine = SanctionEngine.instance;

  void _apply(SanctionAction action) {
    switch (action) {
      case SanctionAction.none:
        Notifier.info(context, 'Nincs szankció (csak naplózva).');
        break;
      case SanctionAction.warn:
        Notifier.warn(context, 'Figyelmeztetés kiadva.');
        break;
      case SanctionAction.suspend14d:
        Notifier.error(context, 'Felfüggesztés 14 napra.');
        break;
      case SanctionAction.banPermanent:
        Notifier.error(context, 'Végleges tiltás.');
        break;
    }
    setState(() {}); // állapot frissítés megjelenítéshez
  }

  @override
  Widget build(BuildContext context) {
    final s = engine.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Szankciók demó')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Jelenlegi állapot (szolgáltató)'),
                subtitle: Text(
                  'Pontok: ${s.points}\n'
                  '1★: ${s.oneStarCount}\n'
                  'Egymást követő no-show: ${s.consecutiveNoShows}\n'
                  'Felfüggesztve eddig: ${s.suspendedUntil?.toIso8601String() ?? "-"}\n'
                  'Végleg tiltva: ${s.banned ? "igen" : "nem"}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _apply(engine.onComplaint()),
                  child: const Text('Panasz (+1 pont, auto warn)'),
                ),
                ElevatedButton(
                  onPressed: () => _apply(engine.onNoShowReportedByCustomer()),
                  child: const Text('No-show (csak megrendelő jelzése számít)'),
                ),
                ElevatedButton(
                  onPressed: () => _apply(engine.onRating(1)),
                  child: const Text('Értékelés: 1★'),
                ),
                ElevatedButton(
                  onPressed: () => _apply(engine.onRating(2)),
                  child: const Text('Értékelés: 2★'),
                ),
                ElevatedButton(
                  onPressed: () => _apply(engine.onRating(5)),
                  child: const Text('Értékelés: 5★ (nincs szankció)'),
                ),
                OutlinedButton(
                  onPressed: () {
                    engine.weeklyReset();
                    Notifier.info(context, 'Heti számlálók nullázva.');
                    setState(() {});
                  },
                  child: const Text('Heti reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
