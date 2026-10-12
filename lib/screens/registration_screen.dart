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
      body: SafeArea(
        top: false,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
            _VerificationRow(
              controller: emailCodeCtrl,
              label: emailSent ? 'Email kód (demó: 123456)' : 'Email kód',
              border: dense,
              verified: emailOk,
              onSend: _sendEmailCode,
              onVerify: _verifyEmail,
            ),
            const SizedBox(height: 8),

            // SMS verifikáció
            _VerificationRow(
              controller: smsCodeCtrl,
              label: smsSent ? 'SMS kód (demó: 123456)' : 'SMS kód',
              border: dense,
              verified: smsOk,
              onSend: _sendSmsCode,
              onVerify: _verifySms,
            ),

            const SizedBox(height: 12),
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

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({
    required this.controller,
    required this.label,
    required this.border,
    required this.verified,
    required this.onSend,
    required this.onVerify,
  });

  final TextEditingController controller;
  final String label;
  final InputBorder border;
  final bool verified;
  final VoidCallback onSend;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final actions = Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: onSend,
                child: const Text('Kód küldése'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: onVerify,
                child: const Text('Ellenőrzés'),
              ),
              Icon(
                verified ? Icons.verified : Icons.cancel,
                color: verified ? Colors.green : Colors.red,
              ),
            ],
          );
          final field = TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              isDense: true,
              border: border,
            ),
          );
          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                field,
                const SizedBox(height: 6),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: field),
              const SizedBox(width: 6),
              actions,
            ],
          );
        },
      );
}
