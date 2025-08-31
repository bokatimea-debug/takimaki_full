import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _photoKeys = <String>[
  'profile_photo_b64','provider_profile_photo_b64','customer_profile_photo_b64','profilePhotoB64','avatar_b64',
];

class ProfilePhotoLoader {
  static Future<ImageProvider?> loadAny() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in _photoKeys) {
      final raw = prefs.getString(k);
      if (raw == null || raw.trim().isEmpty) continue;
      final cleaned = _stripDataUrl(raw) ?? raw;
      try { return MemoryImage(base64Decode(cleaned)); } catch (_) {}
    }
    return null;
  }

  static Future<void> saveForAll(String base64Data) async {
    final prefs = await SharedPreferences.getInstance();
    final cleaned = _stripDataUrl(base64Data) ?? base64Data;
    for (final k in _photoKeys) { await prefs.setString(k, cleaned); }
  }

  static String? _stripDataUrl(String src) {
    final i = src.indexOf(',');
    if (i > 0 && src.substring(0, i).toLowerCase().contains('base64')) return src.substring(i + 1);
    return null;
  }
}

class ProfileAvatar extends StatelessWidget {
  final ImageProvider? background;
  final double radius;
  final Widget? childWhenEmpty;
  const ProfileAvatar({super.key, this.background, this.radius = 48, this.childWhenEmpty});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: background,
      child: background == null ? (childWhenEmpty ?? const Icon(Icons.person, size: 40)) : null,
    );
  }
}
