// lib/screens/provider_edit_profile_screen.dart
import 'package:flutter/material.dart';

class ProviderEditProfileScreen extends StatelessWidget {
  const ProviderEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bioCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil szerkesztése')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(
                labelText: 'Bemutatkozás',
                hintText: 'Pár soros bemutatkozó szöveg...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            const Text(
              'Általános elérhetőségi idő (opcionális)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Ez az információ csak a kereséshez lesz felhasználva, '
                'a profilodon nem jelenik meg.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Mentés'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Profil törlése'),
                    content: const Text('Biztosan törölni akarod a profilodat?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Mégse'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Törlés'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  Navigator.pushNamedAndRemoveUntil(context, '/role_select', (r) => false);
                }
              },
              child: const Text('Profil törlése', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
