import 'package:flutter/material.dart';
import '../session.dart';
import '../models/subscription.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _hasPhoto = false;

  void _pickPhoto() {
    setState(() {
      _hasPhoto = true; // demóban automatikusan van kép
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profilkép beállítva (demó)')),
    );
  }

  bool _validateAndSave() {
    final first = _firstNameCtrl.text.trim();
    if (first.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keresztnév kötelező')),
      );
      return false;
    }
    if (!_hasPhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profilkép kötelező')),
      );
      return false;
    }

    final s = UserSession.instance;
    s.firstName = first;
    s.lastName = _lastNameCtrl.text.trim();
    s.phone = _phoneCtrl.text.trim();
    s.email = _emailCtrl.text.trim();
    s.hasPhoto = _hasPhoto;
    return true;
  }

  Future<void> _guardAndNavigate(UserRole role, VoidCallback go) async {
    final s = UserSession.instance;
    s.startSubscriptionIfNeeded(role);

    final active = s.isSubscriptionActive;
    if (active) {
      go();
      return;
    }

    // Paywall demó
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Előfizetés szükséges'),
        content: Text(
          'A próbaidőszak lejárt (${SubscriptionPolicy.trialLabel(role)}).\n'
          'Előfizetés: 3000 Ft/hó (demó).',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mégse')),
          FilledButton(
            onPressed: () {
              s.activatePaidDemo(); // demó aktiválás
              Navigator.pop(context);
            },
            child: const Text('Aktiválom (demó)'),
          ),
        ],
      ),
    );

    if (s.isSubscriptionActive) go();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = TextStyle(color: Colors.grey.shade700);

    return Scaffold(
      appBar: AppBar(title: const Text('Regisztráció és szerep')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Icon(Icons.local_laundry_service, size: 96, color: theme.colorScheme.primary)),
            const SizedBox(height: 16),

            // Profilkép
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    child: _hasPhoto ? const Icon(Icons.check, size: 40) : const Icon(Icons.person, size: 40),
                  ),
                  Positioned(
                    right: -6,
                    bottom: -6,
                    child: IconButton(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text('Vezetéknév', style: labelStyle),
            const SizedBox(height: 6),
            TextField(controller: _lastNameCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 12),

            Text('Keresztnév *', style: labelStyle),
            const SizedBox(height: 6),
            TextField(controller: _firstNameCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 12),

            Text('Telefonszám', style: labelStyle),
            const SizedBox(height: 6),
            TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 12),

            Text('Email', style: labelStyle),
            const SizedBox(height: 6),
            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(border: OutlineInputBorder())),

            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),

            _RoleActionCard(
              label: 'Megrendelés leadása',
              icon: Icons.shopping_bag,
              color: theme.colorScheme.primary,
              onTap: () async {
                if (_validateAndSave()) {
                  await _guardAndNavigate(UserRole.customer, () {
                    Navigator.pushNamed(context, '/customer/search');
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            _RoleActionCard(
              label: 'Szolgáltatás felvétele',
              icon: Icons.engineering,
              color: theme.colorScheme.secondary,
              onTap: () async {
                if (_validateAndSave()) {
                  await _guardAndNavigate(UserRole.provider, () {
                    Navigator.pushNamed(context, '/provider/setup');
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.5,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

