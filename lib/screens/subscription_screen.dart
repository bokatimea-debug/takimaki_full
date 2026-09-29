import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _customerActive = false;
  bool _providerActive = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _customerActive = prefs.getBool('customer_subscription_active') ?? false;
      _providerActive = prefs.getBool('provider_subscription_active') ?? false;
    });
  }

  Future<void> _setSubscription(String role, bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${role}_subscription_active', active);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          active
              ? 'A tesztelői előfizetés aktív.'
              : 'A tesztelői előfizetést kikapcsoltad.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Előfizetések')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'A megrendelői és szolgáltatói előfizetés külön kezelhető.',
          ),
          const SizedBox(height: 16),
          _SubscriptionCard(
            title: 'Megrendelő',
            description: 'Az első 3 hónap ingyenes, utána 3 000 Ft/hó.',
            active: _customerActive,
            onChanged: (value) => _setSubscription('customer', value),
          ),
          const SizedBox(height: 12),
          _SubscriptionCard(
            title: 'Szolgáltató',
            description:
                'Az első elfogadott megrendelés ingyenes, utána 3 000 Ft/hó.',
            active: _providerActive,
            onChanged: (value) => _setSubscription('provider', value),
          ),
          const SizedBox(height: 18),
          const Card(
            color: Color(0xFFFFF4EC),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Tesztverzió: a kapcsoló a fizetési folyamat tesztelésére szolgál. A végleges kiadásban ezt a Google Play Billing váltja fel.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.title,
    required this.description,
    required this.active,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Chip(label: Text(active ? 'Aktív' : 'Inaktív')),
              ],
            ),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => onChanged(!active),
              child: Text(
                active
                    ? 'Tesztelői előfizetés kikapcsolása'
                    : 'Tesztelői előfizetés aktiválása',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
