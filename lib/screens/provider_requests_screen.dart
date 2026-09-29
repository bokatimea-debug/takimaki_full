import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../services/local_marketplace_store.dart";
import "../services/sanctions_store.dart";

class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({super.key});
  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen> {
  static const String kKey = "provider_requests";
  List<Map<String, dynamic>> _items = [];

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    String? raw = p.getString(kKey);
    if (raw == null || raw.isEmpty) {
      // minimál minta
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final nextDay = DateTime.now().add(const Duration(days: 2));
      String date(DateTime value) =>
          "${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}";
      final samples = [
        {
          "id": "R1",
          "service": "Általános takarítás",
          "customer": "Kiss Anna",
          "address": "Budapest, XI.",
          "date": date(tomorrow),
          "time": "10:00",
          "status": "pending",
          "created_at": DateTime.now().toIso8601String(),
        },
        {
          "id": "R2",
          "service": "Vízszerelés",
          "customer": "Nagy Péter",
          "address": "Budapest, XIII.",
          "date": date(nextDay),
          "time": "14:30",
          "status": "pending",
          "created_at": DateTime.now().toIso8601String(),
        },
      ];
      raw = json.encode(samples);
      await p.setString(kKey, raw);
    }
    final allItems = (json.decode(raw) as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    var changed = false;
    for (final item in allItems) {
      if (item["status"] == "pending" &&
          LocalMarketplaceStore.isResponseExpired(item)) {
        item["status"] = "expired";
        changed = true;
      }
    }
    _items = allItems.where((item) => item["status"] == "pending").toList();
    if (changed) await p.setString(kKey, json.encode(allItems));
    if (mounted) setState(() {});
  }

  Future<void> _reject(int i) async {
    final requestId = (_items[i]['request_id'] ?? _items[i]['id']).toString();
    await LocalMarketplaceStore.updateRequestStatus(requestId, 'rejected');
    await _load();
  }

  Future<void> _quickAccept(int i) async {
    if (await SanctionsStore.isProviderSuspended()) {
      final until = await SanctionsStore.providerSuspendedUntil();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "A szolgáltatói fiók ${until?.toLocal().toString().split(' ').first ?? ''}-ig fel van függesztve.",
          ),
        ),
      );
      return;
    }
    final allowed = await LocalMarketplaceStore.canProviderSendOffer();
    if (!allowed) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Előfizetés szükséges"),
          content: const Text(
            "Az első elfogadott megrendelés ingyenes. További ajánlatokhoz 3 000 Ft/hó szolgáltatói előfizetés szükséges.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/subscriptions");
              },
              child: const Text("Előfizetések"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Rendben"),
            ),
          ],
        ),
      );
      return;
    }
    final item = _items[i];
    final prefs = await SharedPreferences.getInstance();
    final rawServices = prefs.getString("provider_services") ?? "[]";
    final services = (json.decode(rawServices) as List)
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();
    final matching = services.where(
      (service) => service["name"] == item["service"],
    );
    final price = matching.isEmpty
        ? null
        : int.tryParse(matching.first["price_raw"].toString());
    if (price == null || price <= 0) {
      final result = await Navigator.pushNamed(
        context,
        "/provider/offer_reply",
        arguments: item,
      );
      if (result == true) await _load();
      return;
    }
    await LocalMarketplaceStore.sendOffer(
      request: item,
      price: price,
      note: "Gyors elfogadás",
    );
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Az ajánlatot elküldted.")));
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Beérkezett ajánlatkérések")),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final it = _items[i];
          final title = it["service"] ?? "";
          final sub =
              "${it["customer"] ?? ""} • ${it["address"] ?? ""} • ${it["date"] ?? ""} ${it["time"] ?? ""}";
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                final res = await Navigator.pushNamed(
                  context,
                  "/provider/offer_reply",
                  arguments: it,
                );
                if (res == true) await _load();
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(sub),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _reject(i),
                            child: const Text("Elutasítás"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _quickAccept(i),
                            child: const Text("Gyors elfogadás"),
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
    );
  }
}
