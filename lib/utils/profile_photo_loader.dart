import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Lehetséges kulcsok, amik alá a regisztrációnál elmenthettük a base64 képet.
/// Többet is próbálunk, hogy visszafelé kompatibilis legyen.
const List<String> _photoKeys = <String>[
  "profile_photo_b64",
  "customer_profile_photo_b64",
  "provider_profile_photo_b64",
];

/// Betölti az első létező base64 profilképet a megadott kulcsok közül.
/// Siker esetén MemoryImage-et ad vissza, különben null-t.
Future<ImageProvider?> loadProfilePhoto() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    for (final k in _photoKeys) {
      final b64 = prefs.getString(k);
      if (b64 != null && b64.trim().isNotEmpty) {
        try {
          final bytes = base64Decode(b64);
          return MemoryImage(bytes);
        } catch (_) {
          // ha rossz a tartalom, próbáljuk a következő kulcsot
        }
      }
    }
  } catch (_) {}
  return null;
}

/// Egységes avatar, ami automatikusan megpróbálja betölteni a profilképet.
/// Ha nincs, akkor alap ikon jelenik meg.
class ProfileAvatar extends StatelessWidget {
  final double radius;

  const ProfileAvatar({super.key, this.radius = 40});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider?>(
      future: loadProfilePhoto(),
      builder: (context, snap) {
        final img = snap.data;
        if (img != null) {
          return CircleAvatar(radius: radius, backgroundImage: img);
        }
        // alapértelmezett ikon, amíg nincs kép
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, size: 40),
        );
      },
    );
  }
}
