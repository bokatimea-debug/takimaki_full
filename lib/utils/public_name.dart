/// New records carry a separate first name; old Hungarian display names use
/// surname-first order. Never change identity keys to shorten a display label.
String publicName(
  Object? fullName, {
  Object? firstName,
  String fallback = 'Partner',
}) {
  final first = firstName?.toString().trim() ?? '';
  if (first.isNotEmpty) return first;
  final full = fullName?.toString().trim() ?? '';
  if (full.isEmpty) return fallback;
  final parts = full.split(RegExp(r'\s+'));
  return parts.length > 1 ? parts.skip(1).join(' ') : full;
}

String peerNameFor(Map<String, dynamic> record, String role) => publicName(
  record['${role}_name'] ?? record[role],
  firstName: record['${role}_first_name'],
  fallback: role == 'customer' ? 'Megrendelő' : 'Szolgáltató',
);
