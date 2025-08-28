import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'registration_success_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;
  const OtpVerifyScreen({super.key, required this.phone});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> with CodeAutoFill {
  String _code = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  void _verify() {
    setState(() => _error = null);
    if (_code.replaceAll(' ', '') == '123456') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationSuccessScreen()),
        (r) => false,
      );
    } else {
      setState(() => _error = 'Hibás kód, próbáld újra.');
    }
  }

  @override
  void codeUpdated() {
    setState(() {}); // sms_autofill callback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS-kód')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Kód elküldve: ${widget.phone}', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PinFieldAutoFill(
              codeLength: 6,
              currentCode: _code,
              onCodeChanged: (c) => setState(() => _code = c ?? ''),
              decoration: UnderlineDecoration(
                textStyle: const TextStyle(fontSize: 20),
                colorBuilder: FixedColorBuilder(Theme.of(context).colorScheme.primary),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _verify,
                child: const Text('Tovább'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
