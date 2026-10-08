import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/branded_background.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionBadge(
                  icon: Icons.auto_awesome,
                  text: 'Üdv a Takimakiban',
                ),
                const Spacer(),
                Center(
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [takiTealDark, takiTeal],
                      ),
                      borderRadius: BorderRadius.circular(58),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x44006C70),
                          blurRadius: 34,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.cleaning_services_rounded,
                      size: 108,
                      color: takiOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                Text(
                  'Segítség, amikor\nszükséged van rá.',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Gyors ajánlatok, ellenőrizhető profilok és egyszerű egyeztetés egy helyen.',
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.45,
                    color: Color(0xFF617577),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/role'),
                    icon: const Icon(Icons.arrow_forward_rounded),
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
