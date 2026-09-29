import 'package:flutter/material.dart';

import 'otp_verify_screen.dart';
import '../services/account_store.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneCtrl = TextEditingController(text: "+36 ");

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final phone = _phoneCtrl.text.replaceAll(RegExp(r'[^0-9+]'), '');
    if (!RegExp(r'^\+36\d{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adj meg érvényes magyar telefonszámot.')),
      );
      return;
    }
    final blockedUntil = await AccountStore.blockedUntilFor(phone);
    if (blockedUntil != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ezzel a telefonszámmal ${blockedUntil.toLocal().toString().split(' ').first}-ig nem lehet újra regisztrálni.',
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtpVerifyScreen(phone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Telefonszám megerősítése"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Telefonszám",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _continue,
              child: const Text("Kód kérése"),
            ),
          ],
        ),
      ),
    );
  }
}
