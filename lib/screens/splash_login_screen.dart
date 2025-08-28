import 'package:flutter/material.dart';
import 'profile_info_screen.dart';

class SplashLoginScreen extends StatelessWidget {
  const SplashLoginScreen({super.key});

  void _continue(BuildContext context) {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => const ProfileInfoScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 44, child: Icon(Icons.cleaning_services, size: 40)),
            const SizedBox(height: 18),
            const Text('Takimaki', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
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
            const Text('Gyors és biztonságos belépés.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
