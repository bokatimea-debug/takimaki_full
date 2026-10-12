import 'package:flutter/material.dart';

import '../theme.dart';

/// Display filters only; these never change a record or its status.
class TakiStatusTabs extends StatelessWidget {
  const TakiStatusTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final int selected;
  final ValueChanged<int> onChanged;
  static bool shows(Map<String, dynamic> record, int tab) {
    final status = record['status']?.toString();
    final closed = const [
      'Teljesítve',
      'Lemondva',
      'Lezárt',
      'completed',
      'cancelled',
      'closed',
    ].contains(status);
    if (tab == 2) return closed;
    if (tab == 1)
      return const ['Függőben', 'pending', 'offered'].contains(status);
    return !closed;
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 4,
    children: [
      for (var index = 0; index < 3; index++)
        ChoiceChip(
          label: Text(const ['Aktív', 'Függőben', 'Lezárt'][index]),
          selected: selected == index,
          onSelected: (_) => onChanged(index),
          showCheckmark: false,
          selectedColor: takiTeal,
          backgroundColor: index == 1 ? takiCardYellow : takiCardMint,
          side: BorderSide.none,
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected == index ? Colors.white : takiNavy,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
    ],
  );
}
