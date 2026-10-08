import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';

class LocalChatStore {
  static const _key = 'local_chat_threads';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      MockData.threads = [];
      return;
    }
    try {
      MockData.threads = (json.decode(raw) as List)
          .map(
            (item) =>
                MockThread.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      MockData.threads = [];
    }
    await refreshPeers();
    await cleanup();
  }

  static Future<void> refreshPeers() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('active_role');
    if (role != 'provider' && role != 'customer') return;
    final peerRole = role == 'provider' ? 'customer' : 'provider';
    final records = <Map<String, dynamic>>[];
    for (final key in ['${role}_orders', 'provider_requests']) {
      try {
        final raw = prefs.getString(key);
        if (raw != null) {
          records.addAll(
            (jsonDecode(raw) as List).map(
              (entry) => Map<String, dynamic>.from(entry as Map),
            ),
          );
        }
      } on FormatException {
        continue;
      }
    }
    for (final thread in MockData.threads) {
      if (!thread.id.startsWith('request_')) continue;
      final requestId = thread.id.substring('request_'.length);
      for (final record in records) {
        if ((record['request_id'] ?? record['id']).toString() != requestId)
          continue;
        final name = (record['${peerRole}_name'] ?? record[peerRole])
            ?.toString();
        if (name == null || name.trim().isEmpty) continue;
        thread.peerName = name;
        thread.peerFirstName = record['${peerRole}_first_name']?.toString();
        thread.peerRole = peerRole;
        thread.peerId = record['${peerRole}_id']?.toString();
        thread.viewRole = role;
        thread.peerPhotoB64 = record['${peerRole}_photo_b64'] as String?;
        thread.peerPhotoPath = record['${peerRole}_photo_path'] as String?;
        break;
      }
    }
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    for (final thread in MockData.threads) {
      final path = thread.peerPhotoPath;
      if ((thread.peerPhotoB64 == null || thread.peerPhotoB64!.isEmpty) &&
          path != null &&
          path.isNotEmpty) {
        try {
          final bytes = await File(path).readAsBytes();
          if (bytes.isNotEmpty) thread.peerPhotoB64 = base64Encode(bytes);
        } on FileSystemException {
          // Missing peer photos fall back to initials, never the user's image.
        }
      }
    }
    await prefs.setString(
      _key,
      json.encode(MockData.threads.map((thread) => thread.toJson()).toList()),
    );
  }

  static Future<void> cleanup() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    for (final thread in MockData.threads) {
      thread.messages.removeWhere((message) => message.ts.isBefore(cutoff));
    }
    // Keep newly opened conversations even before their first message.
    await save();
  }

  static Future<int> unreadCount(String role) async {
    await load();
    final prefs = await SharedPreferences.getInstance();
    var count = 0;
    for (final thread in MockData.threads) {
      final seen = DateTime.tryParse(
        prefs.getString('chat_read_${role}_${thread.id}') ?? '',
      );
      count += thread.messages
          .where(
            (message) =>
                message.from != 'Én' &&
                (seen == null || message.ts.isAfter(seen)),
          )
          .length;
    }
    return count;
  }

  static Future<void> markThreadRead(String role, String threadId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'chat_read_${role}_$threadId',
      DateTime.now().toIso8601String(),
    );
  }
}
