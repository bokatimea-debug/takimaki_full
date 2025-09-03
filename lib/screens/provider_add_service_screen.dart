import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProviderAddServiceScreen extends StatefulWidget {
  final String? serviceId;
  final Map<String, dynamic>? initial;
  const ProviderAddServiceScreen({super.key, this.serviceId, this.initial});

  @override
  State<ProviderAddServiceScreen> createState() => _ProviderAddServiceScreenState();
}

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController(text: '60');

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _name.text = widget.initial!['name']?.toString() ?? '';
      _price.text = widget.initial!['price']?.toString() ?? '';
      _duration.text = widget.initial!['duration']?.toString() ?? '60';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final col = FirebaseFirestore.instance.collection('users').doc(uid).collection('services');

    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceId == null ? 'Új szolgáltatás' : 'Szolgáltatás szerkesztése')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Megnevezés'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Adj meg nevet' : null,
            ),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Ár (Ft)'),
              validator: (v) => (v == null || int.tryParse(v) == null) ? 'Adj meg számot' : null,
            ),
            TextFormField(
              controller: _duration,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Időtartam (perc)'),
              validator: (v) => (v == null || int.tryParse(v) == null) ? 'Adj meg számot' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final data = {
                  'name': _name.text.trim(),
                  'price': int.parse(_price.text),
                  'duration': int.parse(_duration.text),
                  'updatedAt': FieldValue.serverTimestamp(),
                };
                if (widget.serviceId == null) {
                  data['createdAt'] = FieldValue.serverTimestamp();
                  await col.add(data);
                } else {
                  await col.doc(widget.serviceId).update(data);
                }
                if (mounted) Navigator.pop(context, true);
              },
              child: const Text('Mentés'),
            ),
          ],
        ),
      ),
    );
  }
}
