import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'registration_success_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;

  const OtpVerifyScreen(this.phone, {super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otpCtrl.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A kód 6 számjegyből áll.')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registration_phone', widget.phone);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS-kód"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Kód elküldve: ${widget.phone}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: "Írd be a 6 jegyű kódot",
                counterText: "",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verify,
              child: const Text("Tovább"),
            ),
          ],
        ),
      ),
    );
  }
}
