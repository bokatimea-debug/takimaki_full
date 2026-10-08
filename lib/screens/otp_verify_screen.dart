import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../services/account_store.dart';
import '../widgets/onboarding_components.dart';
import 'registration_success_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;

  const OtpVerifyScreen(this.phone, {super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _otpCtrl = TextEditingController();
  bool _saving = false;
  bool get _valid => RegExp(r'^\d{6}$').hasMatch(_otpCtrl.text.trim());

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_saving) return;
    final code = _otpCtrl.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A kód 6 számjegyből áll.')),
      );
      return;
    }
    setState(() => _saving = true);
    final blockedUntil = await AccountStore.blockedUntilFor(widget.phone);
    if (!mounted) return;
    if (blockedUntil != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'A törölt profil telefonszámával 3 hónapig nem regisztrálhatsz újra.'),
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registration_phone', widget.phone);
    await prefs.setBool('registration_complete', true);
    await AccountStore.markRegistrationCompleted();
    await prefs.setBool('session_active', true);
    if (!prefs.containsKey('customer_trial_started_at')) {
      await prefs.setString(
        'customer_trial_started_at',
        DateTime.now().toIso8601String(),
      );
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegistrationSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Telefonszám ellenőrzése')),
        body: OnboardingBody(
          children: [
            const OnboardingSteps(current: 1),
            OnboardingHeading(
              title: 'Írd be az SMS-kódot',
              subtitle:
                  'A 6 jegyű kódot erre a számra küldtük:\n${widget.phone}',
            ),
            OnboardingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.sms_outlined, color: takiOrange, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Ellenőrző kód',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _otpCtrl,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 7,
                      color: takiNavy,
                    ),
                    decoration: onboardingField(hint: '••••••').copyWith(
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Nem érkezett meg?  Kód újraküldése',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: takiMint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            OnboardingButton(
              label: 'Tovább',
              onPressed: _valid ? _verify : null,
              loading: _saving,
            ),
          ],
        ),
      );
}
