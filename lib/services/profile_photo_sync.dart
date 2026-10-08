import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfilePhotoSync {
  static Future<void> sync(String photo) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('registration_phone');
    for (final role in ['customer', 'provider']) {
      final fullName = [
        prefs.getString('${role}_last_name') ??
            prefs.getString('customer_last_name') ??
            '',
        prefs.getString('${role}_first_name') ??
            prefs.getString('customer_first_name') ??
            '',
      ].where((v) => v.trim().isNotEmpty).join(' ');
      if (fullName.isEmpty && phone == null) continue;
      bool matches(Object? id, Object? name) =>
          (phone != null && phone.isNotEmpty && id == phone) ||
          (id == null && fullName.isNotEmpty && name == fullName);
      for (final key in [
        'provider_requests',
        'customer_offers',
        'customer_orders',
        'provider_orders',
      ]) {
        final raw = prefs.getString(key);
        if (raw == null) continue;
        final records = (jsonDecode(raw) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        for (final item in records) {
          if (matches(item['${role}_id'], item['${role}_name'] ?? item[role])) {
            item['${role}_photo_b64'] = photo;
            item['${role}_photo_path'] = null;
          }
        }
        await prefs.setString(key, jsonEncode(records));
      }
      final raw = prefs.getString('local_chat_threads');
      if (raw != null) {
        final threads = (jsonDecode(raw) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        for (final thread in threads) {
          if (thread['peerRole'] == role &&
              matches(thread['peerId'], thread['peerName'])) {
            thread['peerPhotoB64'] = photo;
            thread['peerPhotoPath'] = null;
          }
        }
        await prefs.setString('local_chat_threads', jsonEncode(threads));
      }
    }
  }
}
