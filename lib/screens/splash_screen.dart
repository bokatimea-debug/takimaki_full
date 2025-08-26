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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
      body: Center(
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
    );
  }
}
