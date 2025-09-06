import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});
  @override
  State<CustomerEditProfileScreen> createState() => _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bio = TextEditingController();
  XFile? _picked;
  final _picker = ImagePicker();

  @override
  void dispose() { _bio.dispose(); super.dispose(); }

  Future<String?> _uploadIfAny(String uid) async {
    if (_picked == null) return null;
    final ref = FirebaseStorage.instance.ref().child("profile_photos/$uid.jpg");
    await ref.putData(await _picked!.readAsBytes(), SettableMetadata(contentType: "image/jpeg"));
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    return Scaffold(
      appBar: AppBar(title: const Text("Profil szerkesztése")),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: userDoc.get(),
        builder: (c, s) {
          final data = s.data?.data() ?? {};
          _bio.text = _bio.text.isEmpty ? (data["bio"] as String? ?? "") : _bio.text;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                OutlinedButton.icon(
                  onPressed: () async { _picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85); setState((){}); },
                  icon: const Icon(Icons.photo),
                  label: Text(_picked==null ? "Profilkép kiválasztása" : "Kép kiválasztva"),
                ),
                TextFormField(
                  controller: _bio,
                  decoration: const InputDecoration(labelText: "Bemutatkozás"),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final update = <String, dynamic>{"bio": _bio.text.trim(), "updatedAt": FieldValue.serverTimestamp()};
                    final url = await _uploadIfAny(uid);
                    if (url != null) update["photoUrl"] = url;
                    await userDoc.update(update);
                    if (mounted) Navigator.pop(context, {"ok": true});
                  },
                  child: const Text("Mentés"),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Profil törlése"),
                        content: const Text("Biztosan törlöd?"),
                        actions: [
                          TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text("Mégse")),
                          ElevatedButton(onPressed: ()=>Navigator.pop(context,true), child: const Text("Törlés")),
                        ],
                      ),
                    );
                    if (ok==true) {
                      await userDoc.update({"deleted": true, "deletedAt": FieldValue.serverTimestamp()});
                      if (mounted) Navigator.pop(context, {"deleted": true});
                    }
                  },
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text("Profil törlése", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
