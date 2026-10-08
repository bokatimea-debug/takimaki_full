import '../widgets/taki_app_bar.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/profile_photo_loader.dart';
import '../widgets/city_picker.dart';
import '../widgets/profile_editor_components.dart';

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  State<CustomerEditProfileScreen> createState() =>
      _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  final _bio = TextEditingController();
  String _firstName = '';
  String _city = 'Budapest';
  String? _photo;
  ImageProvider? _photoImage;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photo = await ProfilePhotoLoader.loadAny(role: 'customer');
      if (!mounted) return;
      setState(() {
        _firstName = prefs.getString('customer_first_name') ??
            prefs.getString('registration_first_name') ??
            prefs.getString('provider_first_name') ??
            '';
        _bio.text = prefs.getString('customer_bio') ?? '';
        _city = prefs.getString('customer_city') ??
            prefs.getString('profile_city') ??
            'Budapest';
        _photoImage = photo;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      _showError('Nem sikerült betölteni a profilt. Próbáld újra.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        imageQuality: 88,
      );
      if (image == null || !mounted) return;
      setState(() {
        _photo = image.path;
        _photoImage = FileImage(File(image.path));
      });
    } catch (_) {
      _showError('Nem sikerült megnyitni a képet. Próbáld újra.');
    }
  }

  Future<void> _pickCity() async {
    FocusScope.of(context).unfocus();
    final city = await showCityPicker(context, selectedCity: _city);
    if (city != null && mounted) setState(() => _city = city);
  }

  Future<void> _save() async {
    if (_saving || _loading) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_photo != null) {
        await ProfilePhotoLoader.saveFromPath(_photo!, role: 'customer');
      }
      await _write(prefs, 'customer_bio', _bio.text.trim());
      await _write(prefs, 'customer_city', _city);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      _showError('Nem sikerült menteni a módosításokat. Próbáld újra.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _write(SharedPreferences prefs, String key, String value) async {
    if (!await prefs.setString(key, value)) {
      throw StateError('Profile save failed');
    }
  }

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: TakiAppBar(title: const Text('Profil szerkesztése')),
        body: ProfileEditorBody(
          children: [
            ProfileEditorCard(
              firstName: _firstName,
              photo: _photoImage,
              bio: _bio,
              city: _city,
              enabled: !_loading && !_saving,
              onPickPhoto: _pickPhoto,
              onPickCity: _pickCity,
            ),
            ProfileEditorActions(
              enabled: !_loading,
              busy: _saving,
              onSave: _save,
            ),
          ],
        ),
      );
}
