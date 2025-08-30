// lib/screens/provider_edit_profile_screen.dart
import "dart:convert";
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";

class ProviderEditProfileScreen extends StatefulWidget {
  const ProviderEditProfileScreen({super.key});
  @override
  State<ProviderEditProfileScreen> createState() => _ProviderEditProfileScreenState();
}

class _ProviderEditProfileScreenState extends State<ProviderEditProfileScreen> {
  final TextEditingController _bioCtrl = TextEditingController();
  Uint8List? pickedPhoto;
  TimeOfDay? _wdFrom,_wdTo,_weFrom,_weTo;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _bioCtrl.text = sp.getString("provider_bio") ?? "";
    final b64 = sp.getString("provider_photo_b64");
    if (b64!=null && b64.isNotEmpty) pickedPhoto = base64Decode(b64);
    _wdFrom = _parse(sp.getString("provider_wd_from"));
    _wdTo   = _parse(sp.getString("provider_wd_to"));
    _weFrom = _parse(sp.getString("provider_we_from"));
    _weTo   = _parse(sp.getString("provider_we_to"));
    if (mounted) setState((){});
  }

  TimeOfDay? _parse(String? v){ if (v==null||!v.contains(":")) return null; final p=v.split(":"); return TimeOfDay(hour:int.tryParse(p[0])??0,minute:int.tryParse(p[1])??0); }
  String _fmt(TimeOfDay? t)=> t==null? "--:--" : "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";

  Future<void> _pickPhoto() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (x==null) return;
    final bytes = await x.readAsBytes();
    setState(()=> pickedPhoto = bytes);
  }

  Future<void> _pickRange({required bool weekend}) async {
    final now = TimeOfDay.now();
    final from = await showTimePicker(context: context, initialTime: weekend? (_weFrom??now):(_wdFrom??now));
    if (from==null) return;
    final to = await showTimePicker(context: context, initialTime: weekend? (_weTo??now):(_wdTo??now));
    if (to==null) return;
    setState((){
      if (weekend){ _weFrom=from; _weTo=to; } else { _wdFrom=from; _wdTo=to; }
    });
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString("provider_bio", _bioCtrl.text.trim());
    if (pickedPhoto!=null) await sp.setString("provider_photo_b64", base64Encode(pickedPhoto!));
    if (_wdFrom!=null) await sp.setString("provider_wd_from", _fmt(_wdFrom));
    if (_wdTo  !=null) await sp.setString("provider_wd_to",   _fmt(_wdTo));
    if (_weFrom!=null) await sp.setString("provider_we_from", _fmt(_weFrom));
    if (_weTo  !=null) await sp.setString("provider_we_to",   _fmt(_weTo));
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
          const Text("Általános elérhetőségi idő", style: TextStyle(fontWeight: FontWeight.w600)),
          const Divider(),
          _TimeRow(label: "Hétköznap", value: "${_fmt(_wdFrom)} – ${_fmt(_wdTo)}", onTap: ()=> _pickRange(weekend: false)),
          const SizedBox(height: 8),
          _TimeRow(label: "Hétvége", value: "${_fmt(_weFrom)} – ${_fmt(_weTo)}", onTap: ()=> _pickRange(weekend: true)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text("Mentés"))),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label; final String value; final VoidCallback onTap;
  const _TimeRow({required this.label, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, title: Text(label), subtitle: Text(value), trailing: const Icon(Icons.schedule), onTap: onTap);
}
