import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RentalCalendarSync {
  static const _feedsKey = 'rental_ical_feeds';
  static const _eventsKey = 'rental_ical_events';

  static Future<List<Map<String, String>>> feeds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_feedsKey);
    return raw == null
        ? <Map<String, String>>[]
        : (jsonDecode(raw) as List)
            .map((e) => Map<String, String>.from(e as Map))
            .toList();
  }

  /// Direct reservation access is a partner integration, not an iCal import.
  /// The old URL-based path is deliberately disabled: it cannot provide the
  /// guest/change information needed for dependable cleaning automation.
  static Future<void> saveFeed(String provider, String url) async {
    throw UnsupportedError(
      'Az iCal-import nem támogatott. Airbnb- vagy Booking-partnerkapcsolat szükséges.',
    );
  }

  static Future<void> removeFeed(String provider) async {
    final list = await feeds();
    list.removeWhere((item) => item['provider'] == provider);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_feedsKey, jsonEncode(list));
  }

  static Future<List<Map<String, String>>> refresh() async {
    // Existing locally cached data remains readable while it ages out, but no
    // device contacts Airbnb or Booking by iCal anymore.
    return events();
  }

  static Future<List<Map<String, String>>> events() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_eventsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Map<String, String>.from(e as Map)).toList();
  }
}
