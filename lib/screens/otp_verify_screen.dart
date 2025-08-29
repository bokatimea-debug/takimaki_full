import 'package:flutter/material.dart';
import 'registration_success_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;
  const OtpVerifyScreen(this.phone, {super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _otpController.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      setState(() => _error = '6 számjegy szükséges');
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegistrationSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS kód megerősítés')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Kód elküldve: ${widget.phone}'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: '6 jegyű kód',
                counterText: '',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _verify,
                child: const Text('Megerősítés'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
