import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Régi és új kulcsok, amik alá a base64 profilfotó kerülhetett.
const List<String> _photoKeys = <String>[
  // új
  "profile_photo_b64",
  "customer_profile_photo_b64",
  "provider_profile_photo_b64",
  // lehetséges régi/eltérő kulcsok
  "profilePhotoB64",
  "profile_photo",
  "profile_b64",
  "user_profile_photo_b64",
  "avatar_b64",
];

Future<ImageProvider?> loadProfilePhoto() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // ha valaha rossz prefixszel ment: whitespace csökkentés
    for (final k in _photoKeys) {
      final b64 = prefs.getString(k);
      if (b64 != null) {
        final s = b64.trim();
        if (s.isNotEmpty) {
          try {
            return MemoryImage(base64Decode(s));
          } catch (_) {/* megyünk tovább a listán */}
        }
      }
    }
  } catch (_) {}
  return null;
}

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
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, size: 40),
        );
      },
    );
  }
}
