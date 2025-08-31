import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

const List<String> _photoKeys = <String>[
  "profile_photo_b64",
  "customer_profile_photo_b64",
  "provider_profile_photo_b64",
  // legacy/eltérő kulcsok
  "profilePhotoB64","profile_photo","profile_b64","user_profile_photo_b64","avatar_b64",
];

Future<ImageProvider?> loadProfilePhoto() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    for (final k in _photoKeys) {
      final s = prefs.getString(k);
      if (s != null && s.trim().isNotEmpty) {
        try { return MemoryImage(base64Decode(s.trim())); } catch (_) {}
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
    // minden buildkor új future — szerkesztés után azonnal frissül
    return FutureBuilder<ImageProvider?>(
      future: loadProfilePhoto(),
      builder: (context, snap) {
        final img = snap.data;
        if (img != null) return CircleAvatar(radius: radius, backgroundImage: img);
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, size: 40),
        );
      },
    );
  }
}
