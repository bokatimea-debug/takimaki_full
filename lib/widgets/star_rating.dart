import "package:flutter/material.dart";

class StarRating extends StatelessWidget {
  final int rating;
  final double size;
  const StarRating({super.key, required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i){
        final filled = i < rating;
        return Icon(filled ? Icons.star : Icons.star_border, size: size, color: Colors.amber);
      }),
    );
  }
}
