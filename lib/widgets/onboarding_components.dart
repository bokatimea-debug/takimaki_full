import 'package:flutter/material.dart';

import '../theme.dart';
import 'branded_background.dart';

/// Shared spacing and surfaces for the three registration steps.
class OnboardingBody extends StatelessWidget {
  final List<Widget> children;

  const OnboardingBody({super.key, required this.children});

  @override
  Widget build(BuildContext context) => BrandedBackground(
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: children,
              ),
            ),
          ),
        ),
      );
}

class OnboardingSteps extends StatelessWidget {
  final int current;

  const OnboardingSteps({super.key, required this.current});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var index = 0; index < 3; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                decoration: BoxDecoration(
                  color: index == current ? takiOrange : takiMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      index < current
                          ? Icons.check_rounded
                          : const [
                              Icons.person_outline,
                              Icons.sms_outlined,
                              Icons.done_all_rounded,
                            ][index],
                      size: 17,
                      color: takiNavy,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        const ['Profil', 'Telefon', 'Kész'][index],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: takiNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
}

class OnboardingHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const OnboardingHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                height: 1.12,
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
                color: takiNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: takiMutedText,
              ),
            ),
          ],
        ),
      );
}

class OnboardingCard extends StatelessWidget {
  final Widget child;

  const OnboardingCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: takiProfileGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: takiTealDark.withValues(alpha: .12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      );
}

class OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const OnboardingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18),
        child: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            backgroundColor: takiOrange,
            foregroundColor: takiNavy,
            disabledBackgroundColor: takiYellowSoft,
            disabledForegroundColor: takiMutedText,
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: loading ? null : onPressed,
          child: loading
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: takiNavy,
                  ),
                )
              : Text(label, textAlign: TextAlign.center),
        ),
      );
}

InputDecoration onboardingField({
  String? label,
  String? hint,
  IconData? icon,
}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, size: 21, color: takiNavy),
      filled: true,
      fillColor: takiFieldSurface,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: takiOrange, width: 2),
      ),
    );
