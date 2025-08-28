import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  void _next() {
    if (!_canContinue) return;
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => const PhoneNumberScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alapadatok')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canContinue ? _next : null,
                child: const Text('Tovább'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
