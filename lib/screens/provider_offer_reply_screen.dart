import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProviderOfferReplyScreen extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> initial;
  const ProviderOfferReplyScreen({super.key, required this.requestId, required this.initial});

  @override
  State<ProviderOfferReplyScreen> createState() => _ProviderOfferReplyScreenState();
}

class _ProviderOfferReplyScreenState extends State<ProviderOfferReplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _price = TextEditingController();
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _price.text = widget.initial['suggestedPrice']?.toString() ?? '';
    _note.text = widget.initial['note']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final requests = FirebaseFirestore.instance.collection('requests');

    return Scaffold(
      appBar: AppBar(title: const Text('Ajánlat megadása')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Megrendelő: ${widget.initial['customerName'] ?? '-'}'),
            const SizedBox(height: 8),
            Text('Feladat: ${widget.initial['serviceName'] ?? '-'}'),
            const Divider(height: 24),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Ajánlott ár (Ft)'),
              validator: (v) => (v == null || int.tryParse(v) == null) ? 'Adj meg számot' : null,
            ),
            TextFormField(
              controller: _note,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Megjegyzés (opcionális)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Ajánlat küldése'),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final offer = {
                  'providerId': uid,
                  'price': int.parse(_price.text),
                  'note': _note.text.trim(),
                  'status': 'sent',
                  'sentAt': FieldValue.serverTimestamp(),
                };
                await requests.doc(widget.requestId).collection('offers').doc(uid).set(offer, SetOptions(merge: true));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajánlat elküldve')));
                  Navigator.pop(context, true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
