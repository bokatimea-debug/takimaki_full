import 'package:flutter/material.dart';

import '../services/workflow_store.dart';
import '../widgets/taki_app_bar.dart';
import '../widgets/branded_background.dart';
import '../theme.dart';

class ProblemTicketsScreen extends StatefulWidget {
  const ProblemTicketsScreen({super.key});
  @override
  State<ProblemTicketsScreen> createState() => _ProblemTicketsScreenState();
}

class _ProblemTicketsScreenState extends State<ProblemTicketsScreen> {
  String _role = 'customer';
  List<Map<String, dynamic>> _tickets = [];
  bool _loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _role = ModalRoute.of(context)?.settings.arguments == 'provider'
        ? 'provider'
        : 'customer';
    _load();
  }

  Future<void> _load() async {
    final tickets = await WorkflowStore.ownTickets(_role);
    if (mounted) setState(() => _tickets = tickets);
  }

  Future<void> _append(Map<String, dynamic> ticket) async {
    final controller = TextEditingController();
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('További információ'),
        content: TextField(controller: controller, maxLines: 4),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hozzáadás'),
          ),
        ],
      ),
    );
    final text = controller.text;
    controller.dispose();
    if (yes == true) {
      await WorkflowStore.appendTicket(ticket['request_id'].toString(), text);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Saját hibajegyek')),
    body: BrandedBackground(
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const TakiPanel(
          color: takiMint,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: takiTealDark),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'A hibajegyek belső adatok, nem nyilvános értékelések.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        if (_tickets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Még nincs hibajegyed.'),
          ),
        for (final t in _tickets)
          TakiPanel(
            color: takiYellowSoft,
            padding: const EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${t['reason']} • ${t['status']}'),
                  Text(t['description'].toString()),
                  for (final u in t['updates'] as List? ?? [])
                    Text(u['text'].toString()),
                  TextButton(
                    onPressed: () => _append(t),
                    child: const Text('További információ hozzáadása'),
                  ),
                ],
              ),
            ),
          ),
      ],
      ),
    ),
  );
}
