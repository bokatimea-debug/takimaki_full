import 'dart:convert';

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
    await cleanup();
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
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
    MockData.threads.removeWhere((thread) => thread.messages.isEmpty);
    await save();
  }
}
