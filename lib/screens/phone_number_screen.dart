import 'package:flutter/material.dart';

import '../services/account_store.dart';
import '../theme.dart';
import '../widgets/onboarding_components.dart';
import 'otp_verify_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneCtrl = TextEditingController(text: '+36 ');
  bool _loading = false;

  bool get _validPhone => RegExp(
        r'^\+36\d{9}$',
      ).hasMatch(_phoneCtrl.text.replaceAll(RegExp(r'[^0-9+]'), ''));

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_loading) return;
    final phone = _phoneCtrl.text.replaceAll(RegExp(r'[^0-9+]'), '');
    if (!RegExp(r'^\+36\d{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adj meg érvényes magyar telefonszámot.')),
      );
      return;
    }
    setState(() => _loading = true);
    final blockedUntil = await AccountStore.blockedUntilFor(phone);
    if (!mounted) return;
    setState(() => _loading = false);
    if (blockedUntil != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ezzel a telefonszámmal ${blockedUntil.toLocal().toString().split(' ').first}-ig nem lehet újra regisztrálni.',
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtpVerifyScreen(phone)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Telefonszám')),
        body: OnboardingBody(
          children: [
            const OnboardingSteps(current: 1),
            const OnboardingHeading(
              title: 'Add meg a telefonszámod',
              subtitle: 'Erre a számra küldjük a 6 jegyű ellenőrző kódot.',
            ),
            OnboardingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.sms_outlined, color: takiOrange, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Telefonszám megerősítése',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    style: const TextStyle(fontSize: 17, color: takiNavy),
                    onChanged: (_) => setState(() {}),
                    decoration: onboardingField(
                      label: 'Telefonszám',
                      hint: '+36 30 123 4567',
                      icon: Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Például: +36 30 123 4567',
                    style: TextStyle(fontSize: 13, color: takiMint),
                  ),
                ],
              ),
            ),
            OnboardingButton(
              label: 'Kód kérése',
              onPressed: _validPhone ? _continue : null,
              loading: _loading,
            ),
          ],
        ),
      );
}
