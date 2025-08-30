import 'package:flutter/material.dart';
import 'role_select_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone; // pl. "+36 30 123 4567" — POZICIONÁLIS paraméter
  const OtpVerifyScreen(this.phone, {super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _otpCtrl.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      setState(() => _error = '6 számjegy szükséges');
      return;
    }
    // SIKER: közvetlenül a Szerepkör választóra lépünk
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Egy képernyőre fér, nincs görgetés
    return Scaffold(
      appBar: AppBar(title: const Text('SMS kód megerősítés')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sms, size: 64),
                const SizedBox(height: 12),
                Text(
                  'Küldtünk egy 6 számjegyű kódot erre a számra:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(widget.phone, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 24),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: '6 jegyű kód',
                    counterText: '',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _verify,
                    child: const Text('Megerősítés'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Demó: újraküldés visszajelzés
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kód újraküldve (demó)')),
                    );
                  },
                  child: const Text('Nem jött meg a kód? Küldés újra'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

