import "package:flutter/material.dart";

class CustomerNewOrderScreen extends StatefulWidget {
  const CustomerNewOrderScreen({super.key});

  @override
  State<CustomerNewOrderScreen> createState() => _CustomerNewOrderScreenState();
}

class _CustomerNewOrderScreenState extends State<CustomerNewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Új rendelés")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ha Maps működik: Autocomplete widget; ha nem: sima TextField fallback
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: "Cím (szöveges)"),
              validator: (v) => (v == null || v.trim().isEmpty) ? "Adj meg címet" : null,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final address = _addressController.text.trim();
                // TODO: itt mentjük Firestore-ba a címet (megye/kerület később kinyerhető geokódból)
                if (mounted) Navigator.pop(context, true);
              },
              child: const Text("Rendelés mentése"),
            ),
          ],
        ),
      ),
    );
  }
}
