import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'phone_number_screen.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final lastCtrl = TextEditingController();
  final firstCtrl = TextEditingController();
  File? photo;

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (x != null) setState(() => photo = File(x.path));
  }

  bool get _canContinue =>
      lastCtrl.text.trim().isNotEmpty &&
      firstCtrl.text.trim().isNotEmpty &&
      photo != null;

  Future<void> _next() async {
    if (!_canContinue) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customer_last_name', lastCtrl.text.trim());
    await prefs.setString('customer_first_name', firstCtrl.text.trim());
    await prefs.setString('registration_photo_path', photo!.path);
    await prefs.setString('customer_photo_path', photo!.path);
    if (!mounted) return;
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => const PhoneNumberScreen()));
  }

  @override
  void dispose() {
    lastCtrl.dispose();
    firstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alapadatok')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: photo != null ? FileImage(photo!) : null,
                  child: photo == null ? const Icon(Icons.person, size: 40) : null,
                ),
                IconButton.filledTonal(
                  onPressed: _pick,
                  icon: const Icon(Icons.add_a_photo),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: lastCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Vezetéknév *',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: firstCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Keresztnév *',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _canContinue ? _next : null,
            child: const Text('Tovább'),
          ),
        ),
      ),
    );
  }
}
