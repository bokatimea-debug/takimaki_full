import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/account_store.dart';

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  State<CustomerEditProfileScreen> createState() =>
      _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _lastNameCtrl.text = prefs.getString('customer_last_name') ?? '';
    _firstNameCtrl.text = prefs.getString('customer_first_name') ?? '';
    _bioCtrl.text = prefs.getString('customer_bio') ?? '';
    _photoPath =
        prefs.getString('customer_photo_path') ??
        prefs.getString('registration_photo_path');
    if (mounted) setState(() {});
  }

  Future<void> _pickPhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
    );
    if (image != null && mounted) setState(() => _photoPath = image.path);
  }

  Future<void> _save() async {
    if (_lastNameCtrl.text.trim().isEmpty ||
        _firstNameCtrl.text.trim().isEmpty ||
        _photoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A név és a profilkép kötelező.')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customer_last_name', _lastNameCtrl.text.trim());
    await prefs.setString('customer_first_name', _firstNameCtrl.text.trim());
    await prefs.setString('customer_bio', _bioCtrl.text.trim());
    await prefs.setString('customer_photo_path', _photoPath!);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _deleteProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil törlése'),
        content: const Text('Biztosan törölni szeretnéd a profilodat?'),
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
    if (confirmed != true) return;
    await AccountStore.deleteAccount();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
  }

  @override
  void dispose() {
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil szerkesztése')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _photoPath == null
                    ? null
                    : FileImage(File(_photoPath!)),
                child: _photoPath == null
                    ? const Icon(Icons.add_a_photo, size: 36)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lastNameCtrl,
            decoration: const InputDecoration(labelText: 'Vezetéknév'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _firstNameCtrl,
            decoration: const InputDecoration(labelText: 'Keresztnév'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Bemutatkozás',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Mentés')),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _deleteProfile,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Profil törlése'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
