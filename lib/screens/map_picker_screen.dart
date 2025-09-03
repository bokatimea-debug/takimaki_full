import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});
  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late GooglePlace _googlePlace;
  List<AutocompletePrediction> predictions = [];

  @override
  void initState() {
    super.initState();
    _googlePlace = GooglePlace("YOUR_GOOGLE_API_KEY"); // TODO: API kulcs
  }

  void _autoCompleteSearch(String value) async {
    var result = await _googlePlace.autocomplete.get(value, language: "hu");
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Válassz címet")),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(hintText: "Írd be a címet"),
            onChanged: _autoCompleteSearch,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                final p = predictions[index];
                return ListTile(
                  title: Text(p.description ?? ""),
                  onTap: () {
                    Navigator.pop(context, p.description);
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
