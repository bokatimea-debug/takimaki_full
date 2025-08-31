import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/profile_photo_loader.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});
  @override State<CustomerProfileScreen> createState() => _S();
}
class _S extends State<CustomerProfileScreen> {
  ImageProvider? _photo; String _name = '';
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final p = await ProfilePhotoLoader.loadAny();
    final first = prefs.getString('customer_first_name') ?? '';
    final last  = prefs.getString('customer_last_name')  ?? '';
    setState((){ _photo = p; _name = [first,last].where((e)=>e.trim().isNotEmpty).join(' '); });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Megrendelő profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: ProfileAvatar(background: _photo, radius: 48, childWhenEmpty: const Icon(Icons.person, size:48))),
          const SizedBox(height: 12),
          Center(child: Text(_name.isEmpty ? 'Megrendelő' : _name)),
          const SizedBox(height: 16),
          FilledButton(onPressed: () async { await Navigator.pushNamed(context, '/customer/edit_profile'); await _load(); }, child: const Text('Profil szerkesztése')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: ()=> Navigator.pushNamed(context, '/customer/orders'), child: const Text('Rendeléseim')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: ()=> Navigator.pushNamed(context, '/customer/messages'), child: const Text('Üzenetek')),
          const SizedBox(height: 8),
          FilledButton(onPressed: ()=> Navigator.pushNamed(context, '/customer/search'), child: const Text('Új rendelés leadása')),
        ]),
      ),
    );
  }
}
