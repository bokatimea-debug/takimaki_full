import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/onboarding_components.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: OnboardingBody(
        children: [
          const OnboardingSteps(current: 2),
          const SizedBox(height: 24),
          OnboardingCard(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: takiOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 44,
                    color: takiNavy,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Minden készen áll!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Elkészült a profilod. A következő lépésben kiválaszthatod, hogy segítséget keresel vagy szolgáltatást kínálsz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.45, color: takiMint),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          OnboardingButton(
            label: 'Tovább',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/calendar_connection',
              (route) => false,
              arguments: 'registration',
            ),
          ),
        ],
      ),
    ),
  );
}
