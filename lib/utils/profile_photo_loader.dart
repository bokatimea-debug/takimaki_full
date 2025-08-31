import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Egységes avatar: ha van [backgroundImage], azt rajzoljuk, különben [child].
class ProfileAvatar extends StatelessWidget {
  final double radius;
  final ImageProvider? backgroundImage;
  final Widget? child;

  const ProfileAvatar({super.key, this.radius = 40, this.backgroundImage, this.child});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: backgroundImage,
      child: backgroundImage == null ? child : null,
    );
  }
}

/// Egyszerű lokális (SharedPreferences) tárolás Base64-gyel.
/// Kulcsok: profile_photo_provider, profile_photo_customer
class ProfilePhotoLoader {
  static String _key(String role) => role == 'provider'
      ? 'profile_photo_provider'
      : 'profile_photo_customer';

  /// Betöltés ImageProvider-ként (null, ha nincs).
  static Future<ImageProvider?> load(String role) async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString(_key(role));
    if (b64 == null || b64.isEmpty) return null;
    try {
      final bytes = base64Decode(b64);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  /// Mentés fájlból (pl. image picker után).
  static Future<void> saveFromFile(String role, String filePath) async {
    final f = File(filePath);
    if (await f.exists()) {
      final bytes = await f.readAsBytes();
      final b64 = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key(role), b64);
    }
  }

  /// Mentés már meglévő bytes-ból.
  static Future<void> saveFromBytes(String role, List<int> bytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(role), base64Encode(bytes));
  }

  /// Törlés
  static Future<void> remove(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(role));
  }
}
