import 'package:flutter/material.dart';
import '../services/notifications.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+36 ');
  final _emailCtrl = TextEditingController();
  bool _hasPhoto = false;

  void _pickPhoto() {
    setState(() => _hasPhoto = true);
    Notifier.success(context, 'Profilkép beállítva (demó)');
  }

  void _register() {
    if (_firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        !_hasPhoto) {
      Notifier.warn(context, 'Minden mező kötelező!');
      return;
    }

    // TODO: Email + SMS verifikáció (helyőrző)
    Notifier.info(context, 'Email és SMS megerősítés szükséges (demó)');

    // Ha minden ok → továbblépés a szerepkör választásra
    Navigator.pushReplacementNamed(context, '/customer/search');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Regisztráció')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    child: _hasPhoto
                        ? const Icon(Icons.check, size: 40)
                        : const Icon(Icons.person, size: 40),
                  ),
                  Positioned(
                    right: -6,
                    bottom: -6,
                    child: IconButton(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameCtrl,
              decoration: const InputDecoration(labelText: 'Vezetéknév *'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _firstNameCtrl,
              decoration: const InputDecoration(labelText: 'Keresztnév *'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Telefonszám *'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email *'),
              keyboardType: TextInputType.emailAddress,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Regisztráció'),
            ),
          ],
        ),
      ),
    );
  }
}

