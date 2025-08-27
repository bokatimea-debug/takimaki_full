import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating; // 0..5
  final int successCount; // sikeres rendelés / teljesítés
  final bool isProvider; // szöveg: rendelés vs teljesítés
  const RatingStars({
    super.key,
    required this.rating,
    required this.successCount,
    required this.isProvider,
  });

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      children: [
        for (var i = 0; i < full; i++)
          const Icon(Icons.star, size: 18, color: Colors.amber),
        if (half) const Icon(Icons.star_half, size: 18, color: Colors.amber),
        for (var i = (half ? full + 1 : full); i < 5; i++)
          const Icon(Icons.star_border, size: 18, color: Colors.amber),
        const SizedBox(width: 8),
        Text(
          isProvider
              ? '$successCount db sikeres teljesítés'
              : '$successCount db sikeres rendelés',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
