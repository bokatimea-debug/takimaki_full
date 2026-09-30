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
      backgroundColor: const Color(0xFFF6FAFA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF006D70), Color(0xFF0FA3A9)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(38),
                    bottomRight: Radius.circular(38),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset('assets/icons/takimaki_icon.png', width: 200, height: 200, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 12),
                    const Text('Takimaki', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text('Segítség, amikor szükséged van rá.', style: TextStyle(color: Colors.white, fontSize: 17)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(children: [
                  const Text('Kezdjük el!', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8C42)),
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
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
                  const Spacer(),
                  const Text('Gyors • egyszerű • biztonságos', style: TextStyle(color: Color(0xFF617577))),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
