import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  State<CustomerEditProfileScreen> createState() => _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  XFile? _picked;
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  String? _displayName;

  Future<String?> _uploadIfNeeded(String uid) async {
    if (_picked == null) return null;
    final path = 'profile_photos/$uid.jpg';
    final ref = FirebaseStorage.instance.ref(path);
    await ref.putData(await _picked!.readAsBytes(), SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil szerkesztése')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                _picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                setState(() {});
              },
              icon: const Icon(Icons.photo),
              label: Text(_picked == null ? 'Profilkép kiválasztása' : 'Kép kiválasztva'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Megjelenített név'),
              onSaved: (v) => _displayName = v?.trim(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                _formKey.currentState!.save();
                final url = await _uploadIfNeeded(uid);
                final update = <String, dynamic>{};
                if (_displayName != null && _displayName!.isNotEmpty) update['displayName'] = _displayName!;
                if (url != null) update['photoUrl'] = url;
                if (update.isNotEmpty) await userDoc.update(update);
                if (mounted) Navigator.pop(context, true);
              },
              child: const Text('Mentés'),
            ),
          ],
        ),
      ),
    );
  }
}
