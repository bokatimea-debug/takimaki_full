import 'package:flutter/material.dart';

class ProviderOfferReplyScreen extends StatefulWidget {
  const ProviderOfferReplyScreen({super.key});

  @override
  State<ProviderOfferReplyScreen> createState() => _ProviderOfferReplyScreenState();
}

class _ProviderOfferReplyScreenState extends State<ProviderOfferReplyScreen> {
  final _priceCtrl = TextEditingController();
  final _noteCtrl  = TextEditingController();

  @override
  void dispose() {
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final p = _priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adj meg árat (Ft)!')));
      return;
    }
    Navigator.pop(context, {
      'ok': true,
      'price': int.parse(p),
      'note': _noteCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final reqId = args['requestId']?.toString() ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Ajánlat küldése')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ajánlatkérés #$reqId', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ár (Ft)',
                helperText: 'Ezres tagolás nélkül írd (pl. 15000)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Megjegyzés (opcionális)',
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('Ajánlat elküldése'),
            ),
          ],
        ),
      ),
    );
  }
}
