import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/phone_formatter.dart';
import 'role_select_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  static const prefKey = 'registered_and_verified';

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final lastCtrl = TextEditingController();
  final firstCtrl = TextEditingController();
  final phoneCtrl = TextEditingController(text: '+36 ');
  final emailCtrl = TextEditingController();

  final emailCodeCtrl = TextEditingController();
  final smsCodeCtrl = TextEditingController();

  bool emailSent = false;
  bool smsSent = false;
  bool emailOk = false;
  bool smsOk = false;

  Future<void> _finish() async {
    if (firstCtrl.text.trim().isEmpty) {
      _snack('A keresztnév kötelező.');
      return;
    }
    if (!emailOk || !smsOk) {
      _snack('Erősítsd meg az emailt és a telefonszámot!');
      return;
    }
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(RegistrationScreen.prefKey, true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      );
    }
  }

  void _sendEmailCode() {
    setState(() => emailSent = true);
    _snack('Demó kód az emailhez: 123456');
  }

  void _sendSmsCode() {
    setState(() => smsSent = true);
    _snack('Demó SMS kód: 123456');
  }

  void _verifyEmail() {
    setState(() => emailOk = (emailCodeCtrl.text.trim() == '123456'));
    if (!emailOk) _snack('Hibás kód.');
  }

  void _verifySms() {
    setState(() => smsOk = (smsCodeCtrl.text.trim() == '123456'));
    if (!smsOk) _snack('Hibás kód.');
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final dense = const OutlineInputBorder();
    return Scaffold(
      appBar: AppBar(title: const Text('Regisztráció')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // kisebb, egy képernyőre férő űrlap
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: lastCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Vezetéknév',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: firstCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Keresztnév *',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [HuPhoneFormatter()],
              decoration: const InputDecoration(
                labelText: 'Telefonszám (+36 xx xxx xxxx)',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // EMAIL verifikáció
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emailCodeCtrl,
                    decoration: InputDecoration(
                      labelText: emailSent ? 'Email kód (demó: 123456)' : 'Email kód',
                      isDense: true,
                      border: dense,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: _sendEmailCode,
                  child: const Text('Kód küldése'),
                ),
                const SizedBox(width: 6),
                FilledButton(
                  onPressed: _verifyEmail,
                  child: const Text('Ellenőrzés'),
                ),
                const SizedBox(width: 6),
                Icon(emailOk ? Icons.verified : Icons.cancel,
                    color: emailOk ? Colors.green : Colors.red),
              ],
            ),
            const SizedBox(height: 8),

            // SMS verifikáció
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: smsCodeCtrl,
                    decoration: InputDecoration(
                      labelText: smsSent ? 'SMS kód (demó: 123456)' : 'SMS kód',
                      isDense: true,
                      border: dense,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: _sendSmsCode,
                  child: const Text('Kód küldése'),
                ),
                const SizedBox(width: 6),
                FilledButton(
                  onPressed: _verifySms,
                  child: const Text('Ellenőrzés'),
                ),
                const SizedBox(width: 6),
                Icon(smsOk ? Icons.verified : Icons.cancel,
                    color: smsOk ? Colors.green : Colors.red),
              ],
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _finish,
                child: const Text('Tovább'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
