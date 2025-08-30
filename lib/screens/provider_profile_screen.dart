// lib/screens/provider_profile_screen.dart
import "dart:convert";
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../services/demo_data.dart";

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});
  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  Uint8List? photo;
  String bio = "";

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    bio = sp.getString("provider_bio") ?? "";
    final b64 = sp.getString("provider_photo_b64") ?? sp.getString("registration_photo_b64");
    if (b64!=null && b64.isNotEmpty) photo = base64Decode(b64);
    if (mounted) setState((){});
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar() => CircleAvatar(
      radius: 44,
      backgroundImage: photo!=null? MemoryImage(photo!) : null,
      child: photo==null? const Icon(Icons.person, size: 44) : null,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltató profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            avatar(),
            const SizedBox(height: 8),
            if (bio.isNotEmpty) Text(bio, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: ()=> Navigator.pushNamed(context, "/provider/edit_profile").then((_){_load();}), child: const Text("Profil szerkesztése"))),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: ()=> Navigator.pushNamed(context, "/provider/services"), child: const Text("Szolgáltatásaim"))),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: ()=> Navigator.pushNamed(context, "/provider/requests"), child: const Text("Beérkezett ajánlatkérések")),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: ()=> Navigator.pushNamed(context, "/provider/messages"), child: const Text("Üzenetek")),
            const Spacer(),
            const Align(alignment: Alignment.centerLeft, child: Text("Legutóbbi munkáim", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: Text(DemoOrders.providerOrders.take(3).map((e)=>"• ${e["title"]} – ${e["status"]}").join("\n"))),
          ],
        ),
      ),
    );
  }
}
