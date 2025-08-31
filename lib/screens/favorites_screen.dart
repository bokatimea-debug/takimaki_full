import "package:flutter/material.dart";
import "../services/favorites_service.dart";

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> ids = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final l = await FavoriteService.list(); if (mounted) setState(()=> ids=l); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kedvenc szolgáltatók")),
      body: ids.isEmpty ? const Center(child: Text("Még nincs kedvenc.")) :
        ListView.separated(
          itemCount: ids.length,
          separatorBuilder: (_, __)=> const Divider(height: 1),
          itemBuilder: (_, i){
            final id = ids[i];
            return ListTile(
              title: Text("Szolgáltató #$id"),
              subtitle: const Text("Gyors újrafoglalás elérhető"),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.orange),
                onPressed: () async { await FavoriteService.toggle(id); await _load(); },
              ),
            );
          },
        ),
    );
  }
}
