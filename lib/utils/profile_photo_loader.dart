import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

const List<String> _photoKeys = <String>[
  "profile_photo_b64",
  "customer_profile_photo_b64",
  "provider_profile_photo_b64",
];

Future<ImageProvider?> loadProfilePhoto() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    for (final k in _photoKeys) {
      final b64 = prefs.getString(k);
      if (b64 != null && b64.trim().isNotEmpty) {
        try {
          final bytes = base64Decode(b64);
          return MemoryImage(bytes);
        } catch (_) {}
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
