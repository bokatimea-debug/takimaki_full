import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'rental_calendar_sync.dart';

/// A booking never becomes a public request by itself. It becomes a private
/// draft which the host reviews and explicitly sends.
class RentalCleaningDrafts {
  static const _key = 'rental_cleaning_drafts_v1';

  static Future<List<Map<String, dynamic>>> all() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((value) => Map<String, dynamic>.from(value as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> generateFromCalendar() async {
    final current = await all();
    final known = current.map((item) => item['booking_key'].toString()).toSet();
    final now = DateTime.now();
    for (final event in await RentalCalendarSync.events()) {
      final checkout = _parseIcalDate(event['end']) ?? _parseIcalDate(event['start']);
      if (checkout == null || checkout.isBefore(DateTime(now.year, now.month, now.day))) continue;
      final bookingKey = '${event['provider']}:${event['uid'] ?? event['start']}';
      if (known.contains(bookingKey)) continue;
      current.add({
        'id': 'draft_${DateTime.now().microsecondsSinceEpoch}_${current.length}',
        'booking_key': bookingKey,
        'booking_title': event['title'] ?? 'Foglalás',
        'provider': event['provider'] ?? 'Naptár',
        'checkout_at': checkout.toIso8601String(),
        'suggested_at': DateTime(checkout.year, checkout.month, checkout.day, 11).toIso8601String(),
        'service': 'Apartmantakarítás',
        'duration_minutes': 120,
        'status': 'draft',
        'created_at': DateTime.now().toIso8601String(),
      });
      known.add(bookingKey);
    }
    await _save(current);
    return current;
  }

  static Future<void> markSent(String id, String requestId) async {
    final drafts = await all();
    final index = drafts.indexWhere((item) => item['id'] == id);
    if (index < 0) return;
    drafts[index] = {...drafts[index], 'status': 'sent', 'request_id': requestId, 'sent_at': DateTime.now().toIso8601String()};
    await _save(drafts);
  }

  static Future<void> _save(List<Map<String, dynamic>> drafts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(drafts));
  }

  static DateTime? _parseIcalDate(String? value) {
    if (value == null || value.length < 8) return null;
    final clean = value.trim();
    final year = int.tryParse(clean.substring(0, 4));
    final month = int.tryParse(clean.substring(4, 6));
    final day = int.tryParse(clean.substring(6, 8));
    if (year == null || month == null || day == null) return null;
    final hour = clean.length >= 13 ? int.tryParse(clean.substring(9, 11)) ?? 0 : 0;
    final minute = clean.length >= 15 ? int.tryParse(clean.substring(11, 13)) ?? 0 : 0;
    return DateTime(year, month, day, hour, minute);
  }
}
