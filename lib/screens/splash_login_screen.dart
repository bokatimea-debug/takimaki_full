import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_info_screen.dart';

class SplashLoginScreen extends StatefulWidget {
  const SplashLoginScreen({super.key});

  @override
  State<SplashLoginScreen> createState() => _SplashLoginScreenState();
}

class _SplashLoginScreenState extends State<SplashLoginScreen> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('registration_phone') ?? '';
    final role = prefs.getString('active_role');

    if (!mounted) return;
    if (phone.isNotEmpty && (role == 'customer' || role == 'provider')) {
      Navigator.pushReplacementNamed(
        context,
        role == 'provider' ? '/provider/profile' : '/customer/profile',
      );
      return;
    }
    setState(() => _checkingSession = false);
  }

  void _continue(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileInfoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/icons/takimaki_icon.png',
                width: 112,
                height: 112,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Takimaki',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.login),
                onPressed: () => _continue(context),
                label: const Text('Folytatás Google-fiókkal'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.apple),
                onPressed: () => _continue(context),
                label: const Text('Folytatás Apple-fiókkal'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Gyors és biztonságos belépés.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
