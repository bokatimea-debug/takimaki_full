import "package:flutter/material.dart";

/// Egyszerű helyettesítő map picker:
/// - most: egy TextField + Mentés (visszaadja a címet)
/// - később: Google Maps Autocomplete/Place Picker integráció
class MapPickScreen extends StatefulWidget {
  const MapPickScreen({super.key});
  @override
  State<MapPickScreen> createState() => _S();
}

class _S extends State<MapPickScreen> {
  final _c = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cím kiválasztása")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Írd be a címet (Google Maps integráció később):"),
            const SizedBox(height: 8),
            TextField(
              controller: _c,
              decoration: const InputDecoration(
                hintText: "pl. 1138 Budapest, Váci út 99.",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: (){
                final v = _c.text.trim();
                if (v.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Adj meg címet")));
                  return;
                }
                Navigator.pop(context, v);
              },
              child: const Text("Mentés"),
            )
          ],
        ),
      ),
    );
  }
}
