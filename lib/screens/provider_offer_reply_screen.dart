import "package:flutter/material.dart";

class ProviderOfferReplyScreen extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic>? initial;
  const ProviderOfferReplyScreen({super.key, required this.requestId, this.initial});

  @override
  State<ProviderOfferReplyScreen> createState() => _ProviderOfferReplyScreenState();
}

class _ProviderOfferReplyScreenState extends State<ProviderOfferReplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajánlat küldése (stub)")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Ajánlat ID: ${widget.requestId}"),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: "Ajánlott ár (Ft)"),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.trim().isEmpty) ? "Adj meg árat" : null,
            ),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: "Megjegyzés"),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                final offer = {
                  "price": _priceCtrl.text.trim(),
                  "note": _noteCtrl.text.trim(),
                  "sentAt": DateTime.now().toIso8601String(),
                };
                // ÁTMENETI: csak visszaadjuk a hívónak, nincs Firestore írás
                Navigator.pop(context, {"ok": true, "offer": offer});
              },
              child: const Text("Ajánlat küldése"),
            ),
          ],
        ),
      ),
    );
  }
}
