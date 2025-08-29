import 'package:flutter/material.dart';
import 'role_select_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key, this.phoneMasked = '+36 ••• •• ••••'});

  final String phoneMasked; // opcionálisan átadható maszkos szám kijelzéshez

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _codeCtrl = TextEditingController();
  String? _error;

  void _onConfirm() {
    final code = _codeCtrl.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      setState(() => _error = '6 számjegy szükséges');
      return;
    }
    // DEMÓ: sikeresnek vesszük, továbblépünk a szerepválasztóra
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Minden kifér egy képernyőre – nincs görgetés.
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS kód megerősítés'),
        centerTitle: false,
      ),
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
                  'Küldtünk egy 6 számjegyű kódot az alábbi számra:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.phoneMasked,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Kód',
                    counterText: '',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _onConfirm(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _onConfirm,
                    child: const Text('Megerősítés'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // DEMÓ: újraküldés felirat; itt még nincs háttérlogika
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
