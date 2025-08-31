import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:geocoding/geocoding.dart" as geo;

class MapPickScreen extends StatefulWidget {
  const MapPickScreen({super.key});
  @override
  State<MapPickScreen> createState() => _MapPickScreenState();
}

class _MapPickScreenState extends State<MapPickScreen> {
  static const _bp = LatLng(47.4979, 19.0402);
  GoogleMapController? _c;
  Marker? _m;
  String? _addr;

  Future<void> _rev(LatLng p) async {
    setState(() { _m = Marker(markerId: const MarkerId("p"), position: p); _addr = "Cím betöltése…"; });
    try {
      final list = await geo.placemarkFromCoordinates(p.latitude, p.longitude, );
      if (list.isNotEmpty) {
        final pl = list.first;
        final s = "${pl.postalCode ?? ""} ${pl.locality ?? ""}, ${pl.thoroughfare ?? ""} ${pl.subThoroughfare ?? ""}".trim();
        setState(() { _addr = s; });
      } else setState(() { _addr = "Nincs cím ehhez a ponthoz"; });
    } catch (_) { setState(() { _addr = "Hiba a geokódnál"; }); }
  }

  void _use() {
    if (_addr==null || _addr!.isEmpty) return;
    Navigator.pop(context, _addr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cím kiválasztása (Térkép)")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: _bp, zoom: 12),
            onMapCreated: (x)=> _c=x,
            onTap: _rev,
            markers: {if (_m!=null) _m!},
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          ),
          if (_addr!=null)
            Positioned(
              left: 12, right: 12, bottom: 96,
              child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(_addr!))),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addr==null? null : _use,
        icon: const Icon(Icons.check), label: const Text("Cím beillesztése"),
      ),
    );
  }
}



