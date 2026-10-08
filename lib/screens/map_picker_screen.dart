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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        const TakiHeroHeader(
          eyebrow: 'Budapest',
          icon: Icons.location_on_outlined,
          title: 'Hol legyen a munka?',
          subtitle:
              'Add meg a pontos címet. A Google Maps címválasztó a következő verzióban kapcsolódik be.',
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
              const SizedBox(height: 16),
              Container(
                height: 190,
                decoration: BoxDecoration(
                  color: takiMint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Stack(
                  children: [
                    Positioned.fill(
                      child: Icon(
                        Icons.map_rounded,
                        size: 118,
                        color: Color(0x3310AAA5),
                      ),
                    ),
                    Center(
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: takiOrange,
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ],
                ),
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
