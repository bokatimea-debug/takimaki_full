import "package:flutter/material.dart";
import "../services/subscription_service.dart";

class SubscriptionScreen extends StatefulWidget {
  final UserRole role;
  const SubscriptionScreen({super.key, required this.role});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionInfo? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final i = await SubscriptionService.get(widget.role);
    if (mounted) setState(()=> _info = i);
  }

  @override
  Widget build(BuildContext context) {
    final i = _info;
    return Scaffold(
      appBar: AppBar(title: const Text("Előfizetés")),
      body: i==null ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Szerep: ${widget.role.name == "customer" ? "Megrendelő" : "Szolgáltató"}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (i.trialUntil!=null)
              Text("Próbaidő vége: ${i.trialUntil!.toLocal()}"),
            if (i.paidUntil!=null)
              Text("Előfizetés érvényes eddig: ${i.paidUntil!.toLocal()}"),
            const SizedBox(height: 12),
            Text("Aktív: ${i.active ? "Igen" : "Nem"}"),
            const Spacer(),
            if (!i.active)
              FilledButton(
                onPressed: () async { await SubscriptionService.startTrial(widget.role); await _load(); },
                child: Text(widget.role==UserRole.customer ? "3 hónap próba indítása" : "1 hónap próba indítása"),
              ),
            if (i.active && i.paidUntil==null)
              OutlinedButton(
                onPressed: () async { 
                  final until = DateTime.now().add(const Duration(days: 30));
                  await SubscriptionService.setPaid(widget.role, until); await _load(); 
                },
                child: const Text("Fizetett 1 hó aktiválása (DEMO)"),
              ),
            TextButton(onPressed: () async { await SubscriptionService.cancel(widget.role); await _load(); }, child: const Text("Leiratkozás / törlés")),
          ],
        ),
      ),
    );
  }
}
