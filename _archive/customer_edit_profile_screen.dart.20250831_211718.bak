import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});
  @override State<CustomerEditProfileScreen> createState()=>_S();
}
class _S extends State<CustomerEditProfileScreen>{
  final intro = TextEditingController();
  String? photoPath;

  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    intro.text = sp.getString('customer_bio') ?? '';
    photoPath  = sp.getString('customer_photo_path') ?? sp.getString('registration_photo_path');
    if(mounted) setState((){});
  }

  Future<void> _pickPhoto() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1280);
    if (x!=null) setState(()=> photoPath = x.path);
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('customer_bio', intro.text.trim());
    if (photoPath!=null && photoPath!.isNotEmpty){
      await sp.setString('customer_photo_path', photoPath!);
      await sp.setString('registration_photo_path', photoPath!); // fallback a megjelenítéshez
    }
    if(!mounted) return; Navigator.pop(context, true);
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Profil szerkesztése')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: (photoPath!=null && photoPath!.isNotEmpty)? FileImage(File(photoPath!)) : null,
                child: (photoPath==null || photoPath!.isEmpty)? const Icon(Icons.add_a_photo, size: 36):null,
              ),
            ),
            const SizedBox(height: 12),
            const Align(alignment: Alignment.centerLeft, child: Text('Bemutatkozás')),
            TextField(controller: intro, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
            const Spacer(),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Mentés'))),
          ],
        ),
      ),
    );
  }
}
