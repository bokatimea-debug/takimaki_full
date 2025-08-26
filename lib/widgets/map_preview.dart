import 'package:flutter/material.dart';

class MapPreview extends StatelessWidget {
  final String address;
  const MapPreview({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade200, Colors.grey.shade100],
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.map, size: 64),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.verified, color: Colors.green, size: 18),
                  const SizedBox(width: 4),
                  const Text('cím validálva (demó)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
