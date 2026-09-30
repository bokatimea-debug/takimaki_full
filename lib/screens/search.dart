import 'package:flutter/material.dart';

import '../models.dart';

/// Compatibility screen kept for older routes.
class SearchScreen extends StatelessWidget {
  final UserRole role;

  const SearchScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
