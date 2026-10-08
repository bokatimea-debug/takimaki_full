import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../services/profile_photo_sync.dart';

/// Reads persisted bytes before legacy temporary file paths. Both app roles
/// belong to the same account, so an explicit photo update updates both roles.
class ProfilePhotoLoader {
  static const _sharedKeys = [
    'profile_photo_b64',
    'profilePhotoB64',
    'avatar_b64',
  ];

  static Uint8List? decodePhoto(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      final raw = value.startsWith('data:')
          ? value.substring(value.indexOf(',') + 1)
          : value;
      final bytes = base64Decode(raw);
      return bytes.isEmpty ? null : bytes;
    } on FormatException {
      return null;
    }
  }

  static Future<ImageProvider?> loadAny({String? role}) async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      ..._sharedKeys,
      if (role != null) '${role}_profile_photo_b64',
      'customer_profile_photo_b64',
      'provider_profile_photo_b64',
      'registration_photo_b64',
    ]) {
      final bytes = decodePhoto(prefs.getString(key));
      if (bytes != null) return MemoryImage(bytes);
    }
    for (final key in [
      if (role != null) '${role}_photo_path',
      'registration_photo_path',
      'customer_photo_path',
      'provider_photo_path',
    ]) {
      final path = prefs.getString(key);
      if (path == null || path.isEmpty) continue;
      try {
        final bytes = await File(path).readAsBytes();
        if (bytes.isNotEmpty) {
          await saveForAll(base64Encode(bytes));
          return MemoryImage(bytes);
        }
      } on FileSystemException {
        // A legacy image-picker cache may have been removed by Android.
      }
    }
    return null;
  }

  static Future<void> saveFromPath(String path, {String? role}) async {
    final bytes = await File(path).readAsBytes();
    if (bytes.isEmpty) throw const FormatException('A profilkép üres.');
    await saveForAll(base64Encode(bytes));
  }

  static Future<void> saveRegistrationPhoto(File file) =>
      saveFromPath(file.path);

  static Future<void> saveForAll(String base64Data) async {
    final bytes = decodePhoto(base64Data);
    if (bytes == null) throw const FormatException('Érvénytelen profilkép.');
    final normalized = base64Encode(bytes);
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      ..._sharedKeys,
      'customer_profile_photo_b64',
      'provider_profile_photo_b64',
      'registration_photo_b64',
    ]) {
      await prefs.setString(key, normalized);
    }
    await ProfilePhotoSync.sync(normalized);
  }
}

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
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: takiMint,
    foregroundColor: takiNavy,
    backgroundImage: background,
    child: background == null
        ? (childWhenEmpty ?? Icon(Icons.person, size: radius * .9))
        : null,
  );
}
