import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../widgets/branded_background.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    final prefs = await SharedPreferences.getInstance();
    final lastName = prefs.getString('customer_last_name') ?? '';
    final firstName = prefs.getString('customer_first_name') ?? '';
    final photoPath = prefs.getString('registration_photo_path') ?? '';

    await prefs.setString('active_role', role);
    await prefs.setBool('session_active', true);
    if (role == 'provider') {
      if (lastName.isNotEmpty) {
        await prefs.setString('provider_last_name', lastName);
      }
      if (firstName.isNotEmpty) {
        await prefs.setString('provider_first_name', firstName);
      }
      if (photoPath.isNotEmpty) {
        await prefs.setString('provider_photo_path', photoPath);
      }
    }

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      role == 'provider' ? '/provider/profile' : '/customer/profile',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionBadge(
                        icon: Icons.auto_awesome,
                        text: 'Válaszd ki a szereped',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Miben segíthetünk?',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'A két mód között később is bármikor válthatsz.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF617577),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: constraints.maxHeight < 760 ? 190 : 208,
                        child: _RoleCard(
                          color: takiTeal,
                          icon: Icons.cleaning_services_rounded,
                          title: 'Munkát keresek',
                          subtitle:
                              'Fogadj megkereséseket, küldj ajánlatot és építsd a hírneved.',
                          action: 'Szolgáltatóként belépek',
                          onTap: () => _selectRole(context, 'provider'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: constraints.maxHeight < 760 ? 190 : 208,
                        child: _RoleCard(
                          color: takiOrange,
                          icon: Icons.home_rounded,
                          title: 'Szakembert keresek',
                          subtitle:
                              'Találd meg a feladathoz illő, elérhető szolgáltatót.',
                          action: 'Megrendelőként belépek',
                          onTap: () => _selectRole(context, 'customer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;
  const _RoleCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    elevation: 9,
    shadowColor: color.withOpacity(.3),
    borderRadius: BorderRadius.circular(28),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -22,
            child: Icon(icon, size: 150, color: Colors.white.withOpacity(.12)),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.22),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white, height: 1.3),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      action,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
