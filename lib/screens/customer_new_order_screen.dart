import "package:flutter/material.dart";

class CustomerNewOrderScreen extends StatefulWidget {
  const CustomerNewOrderScreen({super.key});

  @override
  State<CustomerNewOrderScreen> createState() => _CustomerNewOrderScreenState();
}

class _CustomerNewOrderScreenState extends State<CustomerNewOrderScreen> {
  String? _service;

  final _services = const [
    "Általános takarítás",
    "Nagytakarítás",
    "Felújítás utáni takarítás",
    "Karbantartás",
    "Vízszerelés",
    "Villanyszerelés",
  ];

  void _submit() {
    if (_service == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Válassz szolgáltatást")));
      return;
    }
    Navigator.pushNamed(context, "/offers", arguments: {"service": _service});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Új rendelés leadása")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Szolgáltatás"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _services.map((s) {
                final sel = _service == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: sel,
                  onSelected: (_) => setState(()=> _service = s),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text("Mentés"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
