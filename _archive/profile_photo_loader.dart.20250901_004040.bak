import "dart:convert";
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Egységes kulcs-lista (legacy kompatibilitás)
const _photoKeys = <String>[
  // új
  "profile_photo_b64",
  // legacy szolgáltató / megrendelő specifikus kulcsok
  "provider_profile_photo_b64",
  "customer_profile_photo_b64",
  // régi elnevezések
  "profilePhotoB64",
  "avatar_b64",
];

class ProfilePhotoLoader {
  /// Betölti a profilképet SharedPreferences-ből.
  /// Visszaad egy MemoryImage-et vagy null-t.
  static Future<ImageProvider?> loadAny() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in _photoKeys) {
      final b64 = prefs.getString(k);
      if (b64 != null && b64.trim().isNotEmpty) {
        try {
          final bytes = base64Decode(b64);
          return MemoryImage(bytes);
        } catch (_) {
          // próbálkozzunk dataURL formátummal is
          final cleaned = _stripDataUrl(b64);
          if (cleaned != null) {
            try {
              final bytes = base64Decode(cleaned);
              return MemoryImage(bytes);
            } catch (_) {}
          }
        }
      }
    }
    return null;
  }

  /// Mentés egységes kulcs alá + legacy tükrözés (hogy minden képernyő lássa).
  static Future<void> saveForAll(String base64Data) async {
    final prefs = await SharedPreferences.getInstance();
    final cleaned = _stripDataUrl(base64Data) ?? base64Data;
    for (final k in _photoKeys) {
      await prefs.setString(k, cleaned);
    }
  }

  static String? _stripDataUrl(String src) {
    final idx = src.indexOf(",");
    if (idx > 0 && src.substring(0, idx).contains("base64")) {
      return src.substring(idx + 1);
    }
    return null;
  }
}

/// Egységes profil avatar.
/// - Ha van háttérkép: kerek avatar képpel.
/// - Ha nincs: ikon jelenik meg.
class ProfileAvatar extends StatelessWidget {
  final ImageProvider? background;
  final double radius;
  final Widget? childWhenEmpty;

  const ProfileAvatar({
    super.key,
    this.background,
    this.radius = 48,
    this.childWhenEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: background,
      child: background == null
          ? (childWhenEmpty ?? const Icon(Icons.person, size: 40))
          : null,
    );
  }
}
