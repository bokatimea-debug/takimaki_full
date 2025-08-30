// lib/screens/customer_edit_profile_screen.dart
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "../services/profile_store.dart";

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  State<CustomerEditProfileScreen> createState() => _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  final store = ProfileStore.instance;
  late TextEditingController bioCtrl;
  late TextEditingController weekdayCtrl;
  late TextEditingController weekendCtrl;
  Uint8List? pickedPhoto;

  @override
  void initState() {
    super.initState();
    final c = store.customer;
    bioCtrl = TextEditingController(text: c.bio);
    weekdayCtrl = TextEditingController(text: c.weekdayHours);
    weekendCtrl = TextEditingController(text: c.weekendHours);
    pickedPhoto = c.photoBytes;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        pickedPhoto = bytes;
      });
    }
  }

  void _save() {
    final c = store.customer;
    c.bio = bioCtrl.text.trim();
    c.weekdayHours = weekdayCtrl.text.trim();
    c.weekendHours = weekendCtrl.text.trim();
    c.photoBytes = pickedPhoto;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil szerkesztése")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: pickedPhoto != null ? MemoryImage(pickedPhoto as Uint8List) : null,
                child: pickedPhoto == null
                    ? const Icon(Icons.add_a_photo, size: 36, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(
                labelText: "Bemutatkozás",
                hintText: "Pár soros bemutatkozó szöveg...",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Általános elérhetőségi idő",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: weekdayCtrl,
              decoration: const InputDecoration(
                labelText: "Hétköznap (pl. H–P 9–18)",
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: weekendCtrl,
              decoration: const InputDecoration(
                labelText: "Hétvége (pl. Szo–V 10–16)",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text("Mentés"),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Profil törlése"),
                    content: const Text("Biztosan törölni akarod a profilodat?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Mégse")),
                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Törlés")),
                    ],
                  ),
                );
                if (confirm == true) {
                  store.customer.bio = "";
                  store.customer.weekdayHours = "";
                  store.customer.weekendHours = "";
                  store.customer.photoBytes = null;
                  Navigator.pushNamedAndRemoveUntil(context, "/role_select", (r) => false);
                }
              },
              child: const Text("Profil törlése", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
