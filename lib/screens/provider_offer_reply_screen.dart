import 'package:flutter/material.dart';

class ProviderOfferReplyScreen extends StatefulWidget {
  const ProviderOfferReplyScreen({super.key});

  @override
  State<ProviderOfferReplyScreen> createState() => _ProviderOfferReplyScreenState();
}

class _ProviderOfferReplyScreenState extends State<ProviderOfferReplyScreen> {
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  void _submit() {
    // TODO: backend integráció Firestore offers collection
    final price = _priceController.text.trim();
    final note = _noteController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ajánlat elküldve: $price Ft, $note")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajánlat küldése")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Ajánlott ár (Ft)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: "Megjegyzés"),
              maxLines: 2,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Elküldés"),
            ),
          ],
        ),
      ),
    );
  }
}
