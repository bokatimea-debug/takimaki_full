import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AccountStore {
  static const _deletedPhoneKey = 'deleted_account_phone';
  static const _blockedUntilKey = 'deleted_account_blocked_until';
  static const _blocksKey = 'deleted_account_phone_blocks';
  static const _deletionMarkerKey = 'account_deleted_at';

  static String _normalizePhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0036')) digits = digits.substring(2);
    if (digits.startsWith('06') && digits.length == 11) {
      digits = '36${digits.substring(2)}';
    }
    if (digits.length == 9) digits = '36$digits';
    return digits;
  }

  static Map<String, String> _readBlocks(SharedPreferences prefs) {
    final blocks = <String, String>{};
    final oldPhone = _normalizePhone(prefs.getString(_deletedPhoneKey) ?? '');
    final oldUntil = prefs.getString(_blockedUntilKey);
    if (oldPhone.isNotEmpty && oldUntil != null) blocks[oldPhone] = oldUntil;
    try {
      final stored = jsonDecode(prefs.getString(_blocksKey) ?? '{}');
      if (stored is Map) {
        for (final entry in stored.entries) {
          if (entry.value is String) {
            blocks[_normalizePhone(entry.key.toString())] = entry.value;
          }
        }
      }
    } on FormatException {
      // Legacy keys remain usable if a newer record is malformed.
    }
    return blocks;
  }

  static DateTime _threeMonthsAfter(DateTime date) {
    final target = DateTime(date.year, date.month + 3);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    final create = date.isUtc ? DateTime.utc : DateTime.new;
    return create(target.year, target.month, day, date.hour, date.minute,
        date.second, date.millisecond, date.microsecond);
  }

  /// Local demo persistence. A production restriction needs a server record.
  static Future<void> deleteAccount({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = _normalizePhone(prefs.getString('registration_phone') ?? '');
    final blocks = _readBlocks(prefs);
    if (phone.isNotEmpty) {
      final until = _threeMonthsAfter(now ?? DateTime.now());
      final existing = DateTime.tryParse(blocks[phone] ?? '');
      blocks[phone] =
          (existing != null && existing.isAfter(until) ? existing : until)
              .toIso8601String();
    }
    // Persist restrictions before removing profile/session data, so another
    // deletion cannot erase a previous phone's restriction.
    if (!await prefs.setString(_blocksKey, jsonEncode(blocks))) {
      throw StateError('A törlési korlátozás mentése nem sikerült.');
    }
    if (!await prefs.setString(
      _deletionMarkerKey,
      (now ?? DateTime.now()).toIso8601String(),
    )) {
      throw StateError('A törlés állapotának mentése nem sikerült.');
    }
    for (final key in prefs.getKeys().toList()) {
      if (key != _blocksKey &&
          key != _deletedPhoneKey &&
          key != _blockedUntilKey &&
          key != _deletionMarkerKey) {
        if (!await prefs.remove(key)) {
          throw StateError('A profiladatok törlése nem sikerült.');
        }
      }
    }
  }

  /// Prevents a locally deleted account from being reopened by restored or
  /// partially retained Android app data.
  static Future<bool> enforceDeletedState({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('registration_phone') ?? '';
    final markedDeleted = prefs.containsKey(_deletionMarkerKey);
    final blocked = phone.isNotEmpty &&
        await blockedUntilFor(phone, now: now) != null;
    if (!markedDeleted && !blocked) return false;
    for (final key in prefs.getKeys().toList()) {
      if (key != _blocksKey &&
          key != _deletedPhoneKey &&
          key != _blockedUntilKey &&
          key != _deletionMarkerKey) {
        await prefs.remove(key);
      }
    }
    return true;
  }

  static Future<void> markRegistrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deletionMarkerKey);
  }

  static Future<DateTime?> blockedUntilFor(String phone,
      {DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final until =
        DateTime.tryParse(_readBlocks(prefs)[_normalizePhone(phone)] ?? '');
    if (until == null || !(now ?? DateTime.now()).isBefore(until)) return null;
    return until;
  }
}
