import 'package:flutter/material.dart';

const List<String> _roman = [
  'I','II','III','IV','V','VI','VII','VIII','IX','X',
  'XI','XII','XIII','XIV','XV','XVI','XVII','XVIII','XIX','XX',
  'XXI','XXII','XXIII'
];

/// Kerületválasztó modal: 1..23 indexeket ad vissza (pl. [13,14])
Future<List<int>?> pickDistricts(BuildContext context, List<int> initial) {
  final sel = {...initial}; // set a duplikáció elkerülésére
  return showModalBottomSheet<List<int>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kerületek (I–XXIII)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: List.generate(23, (i) {
                final idx = i + 1;
                final active = sel.contains(idx);
                return FilterChip(
                  selected: active,
                  label: Text(_roman[i]),
                  onSelected: (_) {
                    if (active) { sel.remove(idx); } else { sel.add(idx); }
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(onPressed: () => Navigator.pop(context, <int>[]), child: const Text('Törlés')),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Mégse')),
                const SizedBox(width: 8),
                FilledButton(onPressed: () => Navigator.pop(context, sel.toList()), child: const Text('OK')),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Rövid összefoglaló: „Budapest: I, II +N”
String summarizeDistricts(List<int> selected) {
  if (selected.isEmpty) return 'Nincs kiválasztva';
  final romans = selected.map((i) => _roman[i - 1]).toList()..sort();
  if (romans.length <= 3) return 'Budapest: ${romans.join(", ")}';
  return 'Budapest: ${romans.take(2).join(", ")} +${romans.length - 2}';
}

