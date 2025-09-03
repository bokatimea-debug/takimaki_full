import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  State<CustomerEditProfileScreen> createState() => _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  XFile? _picked;
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  String? _bio;

  Future<String?> _uploadIfNeeded(String uid) async {
    if (_picked == null) return null;
    final path = "profile_photos/$uid.jpg";
    final ref = FirebaseStorage.instance.ref(path);
    await ref.putData(await _picked!.readAsBytes(), SettableMetadata(contentType: "image/jpeg"));
    return await ref.getDownloadURL();
  }

  Future<void> _softDeleteProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection("users").doc(uid);
    await userRef.set({
      "deletedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // Kijelentkeztetés
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    return Scaffold(
      appBar: AppBar(title: const Text("Profil szerkesztése")),
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
              label: Text(_picked == null ? "Profilkép kiválasztása" : "Kép kiválasztva"),
            ),
            // Név nem szerkeszthető – kihagyjuk
            TextFormField(
              decoration: const InputDecoration(labelText: "Bemutatkozás (max 200 karakter)"),
              maxLines: 3,
              maxLength: 200,
              onSaved: (v) => _bio = v?.trim(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                _formKey.currentState!.save();
                final url = await _uploadIfNeeded(uid);
                final update = <String, dynamic>{};
                if (_bio != null && _bio!.isNotEmpty) update["bio"] = _bio!;
                if (url != null) update["photoUrl"] = url;
                if (update.isNotEmpty) await userDoc.set(update, SetOptions(merge: true));
                if (mounted) Navigator.pop(context, true); // StreamBuilder frissít
              },
              child: const Text("Mentés"),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                // Navigator.pushNamed(context, "/subscription");
              },
              icon: const Icon(Icons.workspace_premium),
              label: const Text("Előfizetés kezelése"),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Profil törlése"),
                    content: const Text("Biztosan törlöd a profilodat? A törlést követően 3 hónapig nem regisztrálhatsz újra ezzel az azonosítóval."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Mégse")),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Törlés")),
                    ],
                  ),
                );
                if (ok == true) {
                  await _softDeleteProfile();
                }
              },
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text("Profil törlése", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
