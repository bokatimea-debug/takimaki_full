import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderEditProfileScreen extends StatefulWidget {
  const ProviderEditProfileScreen({super.key});
  @override State<ProviderEditProfileScreen> createState()=>_S();
}
class _S extends State<ProviderEditProfileScreen>{
  final bio = TextEditingController();
  String? photoPath;
  TimeOfDay? wdFrom, wdTo, weFrom, weTo;

  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    bio.text = sp.getString('provider_bio') ?? '';
    photoPath = sp.getString('provider_photo_path') ?? sp.getString('registration_photo_path');
    wdFrom = _parse(sp.getString('provider_wd_from'));
    wdTo   = _parse(sp.getString('provider_wd_to'));
    weFrom = _parse(sp.getString('provider_we_from'));
    weTo   = _parse(sp.getString('provider_we_to'));
    if(mounted) setState((){});
  }

  TimeOfDay? _parse(String? hhmm){
    if(hhmm==null || !hhmm.contains(':')) return null;
    final p = hhmm.split(':'); return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }
  String _fmt(TimeOfDay? t)=> t==null? '--:--' : '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  Future<void> _pickRange({required bool weekend}) async {
    final fromInit = weekend ? (weFrom ?? const TimeOfDay(hour:9, minute:0))
                             : (wdFrom ?? const TimeOfDay(hour:9, minute:0));
    final toInit   = weekend ? (weTo   ?? const TimeOfDay(hour:17, minute:0))
                             : (wdTo   ?? const TimeOfDay(hour:17, minute:0));

    final from = await showTimePicker(context: context, initialTime: fromInit, initialEntryMode: TimePickerEntryMode.dial);
    if (from==null) return;
    final to   = await showTimePicker(context: context, initialTime: toInit,   initialEntryMode: TimePickerEntryMode.dial);
    if (to==null) return;

    setState((){
      if(weekend){ weFrom = from; weTo = to; } else { wdFrom = from; wdTo = to; }
    });
  }

  Future<void> _pickPhoto() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1280);
    if (x!=null) setState(()=> photoPath = x.path);
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('provider_bio', bio.text.trim());
    if (photoPath!=null && photoPath!.isNotEmpty){
      await sp.setString('provider_photo_path', photoPath!);
      await sp.setString('registration_photo_path', photoPath!); // fallback a megjelenítéshez
    }
    if (wdFrom!=null) await sp.setString('provider_wd_from', _fmt(wdFrom));
    if (wdTo  !=null) await sp.setString('provider_wd_to',   _fmt(wdTo));
    if (weFrom!=null) await sp.setString('provider_we_from', _fmt(weFrom));
    if (weTo  !=null) await sp.setString('provider_we_to',   _fmt(weTo));
    if(!mounted) return;
    Navigator.pop(context, true);
  }

  @override Widget build(BuildContext context){
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
                backgroundImage: (photoPath!=null && photoPath!.isNotEmpty)? FileImage(File(photoPath!)) : null,
                child: (photoPath==null || photoPath!.isEmpty)? const Icon(Icons.add_a_photo, size: 36):null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Bemutatkozás'),
          const SizedBox(height: 6),
          TextField(controller: bio, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 20),
          const Text('Általános elérhetőségi idő', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ListTile(
            onTap: ()=> _pickRange(weekend: false),
            title: const Text('Hétköznap'),
            subtitle: Text('${_fmt(wdFrom)} – ${_fmt(wdTo)}'),
            trailing: const Icon(Icons.access_time),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0x22000000))),
          ),
          const SizedBox(height: 8),
          ListTile(
            onTap: ()=> _pickRange(weekend: true),
            title: const Text('Hétvége'),
            subtitle: Text('${_fmt(weFrom)} – ${_fmt(weTo)}'),
            trailing: const Icon(Icons.access_time),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0x22000000))),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Mentés')),
        ],
      ),
    );
  }
}
