import '../widgets/taki_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../widgets/branded_background.dart';

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
      appBar: TakiAppBar(title: const Text('Előfizetések')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            const Text(
              'A megrendelői és szolgáltatói csomagot külön kezelheted.',
              style:
                  TextStyle(fontSize: 14, height: 1.35, color: takiMutedText),
            ),
            const SizedBox(height: 14),
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
            const SizedBox(height: 12),
            const TakiPanel(
              color: takiMint,
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.science_outlined, color: takiTealDark, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tesztverzió: nincs fizetés. A végleges kiadásban Google Play Billing kezeli az előfizetést.',
                      style: TextStyle(
                          fontSize: 12, height: 1.35, color: takiTealDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    return TakiPanel(
      color: title == 'Szolgáltató' ? takiMint : takiYellowSoft,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: takiTealDark),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: takiFieldSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(active ? Icons.check_circle_outline : Icons.schedule,
                        size: 16, color: takiTealDark),
                    const SizedBox(width: 4),
                    Text(active ? 'Aktív' : 'Inaktív',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: takiTealDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(
                  fontSize: 14, height: 1.35, color: takiTealDark)),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              backgroundColor: takiOrange,
              foregroundColor: takiTealDark,
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            onPressed: () => onChanged(!active),
            child:
                Text(active ? 'Tesztelői kikapcsolás' : 'Tesztelői aktiválás'),
          ),
        ],
      ),
    );
  }
}
