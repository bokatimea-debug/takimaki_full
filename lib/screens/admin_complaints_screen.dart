import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../models/sanctions.dart';
import '../services/notifications.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final store = ComplaintStore.instance;
  final engine = SanctionEngine.instance;

  final _provCtrl = TextEditingController();
  final _custCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    store.seedIfEmpty();
  }

  void _apply(SanctionAction action) {
    switch (action) {
      case SanctionAction.none:
        Notifier.info(context, 'Naplózva.');
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
    setState(() {});
  }

  void _addComplaint() {
    final p = _provCtrl.text.trim();
    final c = _custCtrl.text.trim();
    final r = _reasonCtrl.text.trim();
    if (p.isEmpty || c.isEmpty || r.isEmpty) {
      Notifier.error(context, 'Minden mező kötelező.');
      return;
    }
    store.add(providerName: p, customerName: c, reason: r);
    _provCtrl.clear();
    _custCtrl.clear();
    _reasonCtrl.clear();
    // rendszerlogika: panasz => pont + warn kiértékelés
    _apply(engine.onComplaint());
  }

  @override
  Widget build(BuildContext context) {
    final items = store.all.reversed.toList();
    final s = engine.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin – Panaszok'),
        actions: [
          IconButton(
            tooltip: 'Heti reset',
            onPressed: () {
              engine.weeklyReset();
              Notifier.info(context, 'Heti számlálók nullázva.');
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Szolgáltató fegyelmi állapot', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text('Pontok: ${s.points}')),
                      Expanded(child: Text('1★: ${s.oneStarCount}')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Egymást követő no-show: ${s.consecutiveNoShows}')),
                      Expanded(child: Text('Felfüggesztve eddig: ${s.suspendedUntil?.toIso8601String() ?? "-"}')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Felfüggesztések száma: ${s.suspensionsCount}')),
                      Expanded(child: Text('Végleg tiltva: ${s.banned ? "igen" : "nem"}')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => _apply(SanctionAction.warn),
                        child: const Text('Figyelmeztetés'),
                      ),
                      OutlinedButton(
                        onPressed: () => _apply(SanctionAction.suspend14d),
                        child: const Text('Felfüggesztés 14 nap'),
                      ),
                      OutlinedButton(
                        onPressed: () => _apply(SanctionAction.banPermanent),
                        child: const Text('Végleges tiltás'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _provCtrl,
                    decoration: const InputDecoration(labelText: 'Szolgáltató neve', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _custCtrl,
                    decoration: const InputDecoration(labelText: 'Megrendelő neve', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _reasonCtrl,
                    decoration: const InputDecoration(labelText: 'Indok', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addComplaint,
                  child: const Text('Hozzáad'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 0),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final c = items[i];
                return ListTile(
                  leading: const Icon(Icons.report_problem_outlined, color: Colors.orange),
                  title: Text('${c.providerName} • ${c.customerName}'),
                  subtitle: Text('${c.reason}\n${c.at.toLocal()}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (key) {
                      switch (key) {
                        case 'warn':
                          _apply(SanctionAction.warn);
                          break;
                        case 'suspend':
                          _apply(SanctionAction.suspend14d);
                          break;
                        case 'ban':
                          _apply(SanctionAction.banPermanent);
                          break;
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'warn', child: Text('Figyelmeztetés')),
                      PopupMenuItem(value: 'suspend', child: Text('Felfüggesztés 14 nap')),
                      PopupMenuItem(value: 'ban', child: Text('Végleges tiltás')),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
