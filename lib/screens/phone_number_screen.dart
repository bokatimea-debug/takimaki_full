import 'package:flutter/material.dart';
import '../utils/phone_formatter.dart';
import 'otp_verify_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final _phoneCtrl = TextEditingController(text: '+36 ');
  final _formKey = GlobalKey<FormState>();

  String? _validate(String? v) {
    final t = v?.trim() ?? '';
    if (!t.startsWith('+36')) return 'A telefonszám +36-tal kezdődjön';
    final d = t.replaceAll(RegExp(r'[^\d]'), '');
    if (d.length < 11) return 'Add meg a teljes számot';
    return null;
  }

  void _next() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => OtpVerifyScreen(phone: _phoneCtrl.text.trim())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Telefonszám')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [HuPhoneFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Telefonszám *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: _validate,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: const Text('Tovább'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
