import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class ProviderEditProfileScreen extends StatefulWidget {
  const ProviderEditProfileScreen({super.key});
  @override
  State<ProviderEditProfileScreen> createState() => _ProviderEditProfileScreenState();
}

class _ProviderEditProfileScreenState extends State<ProviderEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioCtrl = TextEditingController();
  XFile? _picked;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    _picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil szerkesztése (stub)")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OutlinedButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.photo),
              label: Text(_picked == null ? "Profilkép kiválasztása" : "Kép kiválasztva"),
            ),
            TextFormField(
              controller: _bioCtrl,
              decoration: const InputDecoration(labelText: "Bemutatkozás"),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                // ÁTMENETI: nincs mentés, csak visszalépünk és jelezzük, hogy „ok”
                Navigator.pop(context, {"ok": true, "bio": _bioCtrl.text, "picked": _picked?.path});
              },
              child: const Text("Mentés"),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () { /* később: előfizetés képernyő */ },
              icon: const Icon(Icons.workspace_premium),
              label: const Text("Előfizetés kezelése"),
            ),
            TextButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Profil törlése"),
                    content: const Text("Átmeneti stub: itt még nincs tényleges törlés."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Mégse")),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ok")),
                    ],
                  ),
                );
                if (ok == true && mounted) Navigator.pop(context, {"deleted": true});
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
