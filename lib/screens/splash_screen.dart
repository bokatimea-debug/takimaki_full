import 'package:flutter/material.dart';
import '../session.dart';
import 'role_select_screen.dart';
import 'customer_profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ha már regisztrált, automatikus továbblépés
    Future.delayed(const Duration(milliseconds: 600), () {
      final s = UserSession.instance;
      if (s.isRegistered) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerProfileScreen()),
        );
      }
    });
  }

  void _openTestMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Teszt menü', style: TextStyle(fontWeight: FontWeight.w600))),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.local_offer_outlined),
              title: const Text('Ajánlatok demó'),
              onTap: () => Navigator.pushNamed(context, '/offers/demo'),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Chat demó'),
              onTap: () => Navigator.pushNamed(context, '/chat/demo'),
            ),
            ListTile(
              leading: const Icon(Icons.gavel_outlined),
              title: const Text('Szankciók demó'),
              onTap: () => Navigator.pushNamed(context, '/moderation/demo'),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Értesítések beállításai'),
              onTap: () => Navigator.pushNamed(context, '/settings/notifications'),
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Megrendelő kereső'),
              onTap: () => Navigator.pushNamed(context, '/customer/search'),
            ),
            ListTile(
              leading: const Icon(Icons.engineering),
              title: const Text('Szolgáltatói setup'),
              onTap: () => Navigator.pushNamed(context, '/provider/setup'),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Megrendelő profil'),
              onTap: () => Navigator.pushNamed(context, '/customer/profile'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // helyőrző ikon a maki logóhoz
                const Icon(Icons.pets, size: 100, color: Colors.teal),
                const SizedBox(height: 24),
                Text(
                  'Takimaki',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kezdés'),
                ),
              ],
            ),
          ),
          // jobb alsó sarok: Teszt menü
          Positioned(
            right: 12,
            bottom: 12,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _openTestMenu,
              icon: const Icon(Icons.menu),
              label: const Text('Teszt menü'),
            ),
          ),
        ],
      ),
    );
  }
}
