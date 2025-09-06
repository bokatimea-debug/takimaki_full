import "package:flutter/material.dart";

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
  final _duration = TextEditingController(text: "60");

  @override
  void initState() {
    super.initState();
    final m = widget.initial ?? {};
    _name.text = (m["name"] ?? "").toString();
    _price.text = (m["price"] ?? "").toString();
    _duration.text = (m["duration"] ?? "60").toString();
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _duration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceId == null ? "Új szolgáltatás" : "Szolgáltatás szerkesztése")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: "Megnevezés"),
              validator: (v) => (v == null || v.trim().isEmpty) ? "Adj meg nevet" : null,
            ),
            TextFormField(
              controller: _price,
              decoration: const InputDecoration(labelText: "Ár (Ft)"),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || int.tryParse(v) == null) ? "Adj meg számot" : null,
            ),
            TextFormField(
              controller: _duration,
              decoration: const InputDecoration(labelText: "Időtartam (perc)"),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || int.tryParse(v) == null) ? "Adj meg számot" : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                // ÁTMENETI: itt nem írunk Firestore-ba, csak visszalépünk és jelezzük a hívónak
                if (mounted) Navigator.pop(context, {"ok": true, "local": {
                  "name": _name.text.trim(),
                  "price": int.parse(_price.text),
                  "duration": int.parse(_duration.text),
                }});
              },
              child: const Text("Mentés"),
            ),
          ],
        ),
      ),
    );
  }
}
