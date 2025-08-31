import "package:flutter/material.dart";

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});
  @override
  State<CustomerEditProfileScreen> createState() => _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  final _nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil szerkesztése")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Név"),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil mentve"))
                );
                Navigator.pop(context);
              },
              child: const Text("Mentés"),
            ),
          ],
        ),
      ),
    );
  }
}
