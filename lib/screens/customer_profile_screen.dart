import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../utils/profile_photo_loader.dart";
import "../services/local_marketplace_store.dart";
import "../services/sanctions_store.dart";

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});
  @override
  State<CustomerProfileScreen> createState() => _S();
}

class _S extends State<CustomerProfileScreen> {
  ImageProvider? _photo;
  String _name = "";
  String _bio = "";
  int _success = 0;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final p = await ProfilePhotoLoader.loadAny();
    final first = prefs.getString("customer_first_name") ?? "";
    final last = prefs.getString("customer_last_name") ?? "";
    if (!mounted) return;
    setState(() {
      _photo = p;
      _name = [last, first].where((e) => e.trim().isNotEmpty).join(" ");
      _bio = prefs.getString("customer_bio") ?? "";
      _success = prefs.getInt("customer_success_count") ?? 0;
      _rating = prefs.getDouble("customer_rating") ?? 0;
    });
  }

  Future<void> _newOrder() async {
    if (await SanctionsStore.isCustomerSuspended()) {
      final until = await SanctionsStore.customerSuspendedUntil();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Fiók felfüggesztve"),
          content: Text(
            "Késői lemondások miatt ${until?.toLocal().toString().split(' ').first ?? ''}-ig nem adhatsz le új rendelést.",
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Rendben"),
            ),
          ],
        ),
      );
      return;
    }
    final allowed = await LocalMarketplaceStore.canCustomerCreateOrder();
    if (!mounted) return;
    if (allowed) {
      Navigator.pushNamed(context, "/customer/search");
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Előfizetés szükséges"),
        content: const Text(
          "A 3 hónapos ingyenes időszak lejárt. Új rendeléshez 3 000 Ft/hó megrendelői előfizetés szükséges.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscriptions');
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
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Megrendelő profil"),
        actions: [
          IconButton(
            tooltip: "Beállítások",
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: "Szerepváltás",
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/role_select'),
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
        
          children: [
            Center(
              child: ProfileAvatar(
                background: _photo,
                radius: 48,
                childWhenEmpty: const Icon(Icons.person, size: 48),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _name.isEmpty ? "Megrendelő" : _name,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (_bio.isNotEmpty) ...[
              const SizedBox(height: 6),
              Center(child: Text(_bio, textAlign: TextAlign.center)),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 20, color: Color(0xFFFF8C42)),
                Text(
                  _rating == 0
                      ? " Még nincs értékelés"
                      : " ${_rating.toStringAsFixed(1)}",
                ),
                const SizedBox(width: 18),
                Text("$_success sikeres rendelés"),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await Navigator.pushNamed(context, "/customer/edit_profile");
                await _load();
              },
              child: const Text("Profil szerkesztése"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, "/customer/orders"),
              child: const Text("Rendeléseim"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, "/customer/messages"),
              child: const Text("Üzenetek"),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _newOrder,
              child: const Text("Új rendelés leadása"),
            ),
          ],
        ),
      ),
    );
  }
}
