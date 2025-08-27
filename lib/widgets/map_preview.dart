import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPreview extends StatelessWidget {
  final String address;
  const MapPreview({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    const budapest = LatLng(47.4979, 19.0402);

    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(target: budapest, zoom: 11.5),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        liteModeEnabled: true,
        markers: {
          Marker(
            markerId: const MarkerId('addr'),
            position: budapest,
            infoWindow: InfoWindow(title: 'Budapest', snippet: address),
          ),
        },
      ),
    );
  }
}
