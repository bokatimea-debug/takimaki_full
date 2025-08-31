import "dart:io";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Egységes, rugalmas betöltő:
/// - szerepkör-specifikus kulcsok
/// - regisztrációs fallback kulcsok
/// - általános (auth/google) url/fájl fallback
class ProfilePhotoLoader {
  static Future<ImageProvider?> load(String role) async {
    final sp = await SharedPreferences.getInstance();

    // 1) szerepkör-specifikus
    final rolePath = sp.getString("${role}_photo_path");
    final roleB64  = sp.getString("${role}_photo_b64");
    final roleUrl  = sp.getString("${role}_photo_url");

    // 2) regisztrációból örökölt
    final regPath  = sp.getString("registration_photo_path");
    final regB64   = sp.getString("registration_photo_b64");
    final regUrl   = sp.getString("registration_photo_url");

    // 3) általános fallback (auth/google)
    final anyUrl   = sp.getString("user_photo_url") ?? sp.getString("google_photo_url");
    final anyPath  = sp.getString("profile_photo_path") ?? sp.getString("reg_photo");

    return _from(b64: roleB64, path: rolePath, url: roleUrl)
        ?? _from(b64: regB64,  path: regPath,  url: regUrl)
        ?? _from(path: anyPath, url: anyUrl);
  }

  static ImageProvider? _from({String? b64, String? path, String? url}) {
    if (b64 != null && b64.isNotEmpty) {
      try { return MemoryImage(const Base64Decoder().convert(b64)); } catch (_) {}
    }
    if (path != null && path.isNotEmpty) {
      final f = File(path);
      if (f.existsSync()) return FileImage(f);
    }
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }
    return null;
  }
}
