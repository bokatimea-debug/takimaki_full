// lib/screens/customer_edit_profile_screen.dart
import "dart:convert";
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});
  @override
  State<CustomerEditProfileScreen> createState() => _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  final TextEditingController _bioCtrl = TextEditingController();
  Uint8List? pickedPhoto;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _bioCtrl.text = sp.getString("customer_bio") ?? "";
    final b64 = sp.getString("customer_photo_b64");
    if (b64!=null && b64.isNotEmpty) pickedPhoto = base64Decode(b64);
    if (mounted) setState((){});
  }

  Future<void> _pickPhoto() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (x==null) return;
    final bytes = await x.readAsBytes();
    setState(()=> pickedPhoto = bytes);
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString("customer_bio", _bioCtrl.text.trim());
    if (pickedPhoto!=null) await sp.setString("customer_photo_b64", base64Encode(pickedPhoto!));
    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mentve"))); Navigator.pop(context, true); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil szerkesztése")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: pickedPhoto!=null? MemoryImage(pickedPhoto!) : null,
              child: pickedPhoto==null? const Icon(Icons.add_a_photo, size: 36) : null,
            ),
          ),
          const SizedBox(height: 12),
          const Text("Bemutatkozás"),
          const SizedBox(height: 8),
          TextField(controller: _bioCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Pár mondat magadról...")),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text("Mentés"))),
        ],
      ),
    );
  }
}
