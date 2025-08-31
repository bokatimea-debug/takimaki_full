import 'package:flutter/material.dart';
import '../utils/profile_photo_loader.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});
  @override
  State<CustomerProfileScreen> createState() => _S();
}
class _S extends State<CustomerProfileScreen>{
  ImageProvider? _photo;
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async {
    _photo = await ProfilePhotoLoader.load('customer');
    if(!mounted) return; setState((){});
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Megrendelő profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProfileAvatar(radius:48, backgroundImage: _photo, child: _photo==null? const Icon(Icons.person, size:48):null),
            const SizedBox(height: 12),
            FilledButton(onPressed: ()=> Navigator.pushNamed(context, '/customer/edit').then((_){_load();}), child: const Text('Profil szerkesztése')),
            const SizedBox(height: 8),
            FilledButton(onPressed: ()=> Navigator.pushNamed(context, '/customer/new_order'), child: const Text('Új rendelés leadása')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: ()=> Navigator.pushNamed(context, '/chat'), child: const Text('Üzenetek')),
            const SizedBox(height: 16),
            const Align(alignment: Alignment.centerLeft, child: Text('Legutóbbi rendeléseim', style: TextStyle(fontWeight: FontWeight.w700))),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(title: Text('Takarítás'), subtitle: Text('Teljesítve')),
                  ListTile(title: Text('Villanyszerelés'), subtitle: Text('Lemondva')),
                  ListTile(title: Text('Nagytakarítás'), subtitle: Text('Teljesítve')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

