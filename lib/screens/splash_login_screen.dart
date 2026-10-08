import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../services/account_store.dart';
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
    final deleted = await AccountStore.enforceDeletedState();
    final prefs = await SharedPreferences.getInstance();
    final sessionActive = prefs.getBool('session_active') ?? false;
    final role = prefs.getString('active_role');

    if (!mounted) return;
    if (!deleted && sessionActive && (role == 'customer' || role == 'provider')) {
      Navigator.pushReplacementNamed(
        context,
        role == 'provider' ? '/provider/profile' : '/customer/profile',
      );
      return;
    }
    setState(() => _checkingSession = false);
  }

  Future<void> _continue(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final registered = prefs.getBool('registration_complete') ?? false;
    final role = prefs.getString('active_role');
    await prefs.setBool('session_active', true);
    if (!context.mounted) return;
    if (registered) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        role == 'provider'
            ? '/provider/profile'
            : role == 'customer'
            ? '/customer/profile'
            : '/role_select',
        (route) => false,
      );
      return;
    }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00676B), Color(0xFF00AAA6), Color(0xFF087D80)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
            child: Column(
              children: [
                const Text(
                  'TakiMaki',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    letterSpacing: -1.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 330,
                        height: 330,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .08),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Image.asset(
                            'assets/images/takimaki_mascot.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: takiOrange,
                      foregroundColor: takiNavy,
                    ),
                    onPressed: () => _continue(context),
                    label: const Text('Kezdés'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
