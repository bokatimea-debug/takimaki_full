import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;              // 0..5
  final void Function(int)? onChanged; // ha null, csak megjelenítés

  const StarRating({super.key, required this.rating, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final r = rating.clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < r;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.star,
              color: filled ? Colors.amber : Colors.grey, size: 20),
          onPressed: onChanged == null ? null : () => onChanged!(i + 1),
          tooltip: onChanged == null ? null : '${i + 1} csillag',
        );
      }),
    );
  }
}
