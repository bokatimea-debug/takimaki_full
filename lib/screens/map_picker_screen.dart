import '../widgets/taki_app_bar.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/branded_background.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});
  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final _address = TextEditingController();
  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _use() {
    final value = _address.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Írd be a címet.')));
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Helyszín megadása')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
      children: [
        const TakiHeroHeader(
          eyebrow: 'Cím megadása',
          icon: Icons.location_on_outlined,
          title: 'Hol legyen a munka?',
          subtitle:
              'Írd be a pontos címet. A címjavaslatokhoz Google Maps-konfiguráció szükséges.',
        ),
        const SizedBox(height: 24),
        TakiPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _address,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cím',
                  hintText: 'Budapest, Példa utca 12.',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'A címet ellenőrizd mentés előtt.',
                style: TextStyle(color: takiMutedText),
              ),
            ],
          ),
        ),
      ],
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: FilledButton.icon(
          onPressed: _use,
          icon: const Icon(Icons.check),
          label: const Text('Cím használata'),
        ),
      ),
    ),
  );
}
