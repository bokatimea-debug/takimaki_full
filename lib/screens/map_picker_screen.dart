// lib/screens/map_picker_screen.dart
import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:geocoding/geocoding.dart" as geo;

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});
  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const _mapsEnabled = bool.fromEnvironment(
    'MAPS_ENABLED',
    defaultValue: false,
  );
  GoogleMapController? _ctrl;
  LatLng _center = const LatLng(47.4979, 19.0402); // Budapest
  final _addrCtrl = TextEditingController();
  Marker? _pin;
  int? _district;

  int? _districtFromPlacemark(geo.Placemark place) {
    final postal = place.postalCode ?? "";
    if (postal.length == 4 && postal.startsWith("1")) {
      final value = int.tryParse(postal.substring(1, 3));
      if (value != null && value >= 1 && value <= 23) return value;
    }
    return null;
  }

  @override
  void dispose() {
    _addrCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _addrCtrl.text.trim();
    if (q.isEmpty) return;
    try {
      final results = await geo.locationFromAddress(q);
      if (results.isNotEmpty) {
        final loc = results.first;
        final p = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _center = p;
          _pin = Marker(markerId: const MarkerId("pick"), position: p);
        });
        final places = await geo.placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        if (places.isNotEmpty) _district = _districtFromPlacemark(places.first);
        await _ctrl?.animateCamera(CameraUpdate.newLatLngZoom(p, 15));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "A térképes keresés nem elérhető. A címet kézzel is megadhatod.",
          ),
        ),
      );
    }
  }

  Future<void> _use() async {
    final address = _addrCtrl.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Add meg a címet.")));
      return;
    }
    if (_district == null) {
      try {
        final locations = await geo.locationFromAddress(address);
        if (locations.isNotEmpty) {
          final places = await geo.placemarkFromCoordinates(
            locations.first.latitude,
            locations.first.longitude,
          );
          if (places.isNotEmpty) _district = _districtFromPlacemark(places.first);
        }
      } catch (_) {}
    }
    if (!mounted) return;
    Navigator.pop(context, {"address": address, "district": _district});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cím megadása")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addrCtrl,
                    decoration: const InputDecoration(
                      hintText: "Írd be a címet...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                if (_mapsEnabled) ...[
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _search,
                    child: const Text("Keresés"),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _mapsEnabled
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 12,
                    ),
                    onMapCreated: (c) => _ctrl = c,
                    markers: _pin == null ? {} : {_pin!},
                    onTap: (p) => setState(() {
                      _pin = Marker(
                        markerId: const MarkerId("pick"),
                        position: p,
                      );
                    }),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  )
                : const Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_outlined, size: 64),
                        SizedBox(height: 12),
                        Text(
                          "Írd be a teljes budapesti címet. A térképes címválasztás a Google Maps beállítása után lesz elérhető.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _use,
                child: const Text("Cím beillesztése"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
