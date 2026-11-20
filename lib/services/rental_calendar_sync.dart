import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class RentalCalendarSync {
  static const _feedsKey = 'rental_ical_feeds';
  static const _eventsKey = 'rental_ical_events';

  static Future<List<Map<String, String>>> feeds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_feedsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Map<String, String>.from(e as Map)).toList();
  }

  static Future<void> saveFeed(String provider, String url) async {
    final list = await feeds();
    list.removeWhere((item) => item['provider'] == provider);
    list.add({'provider': provider, 'url': url.trim()});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_feedsKey, jsonEncode(list));
  }

  static Future<void> removeFeed(String provider) async {
    final list = await feeds();
    list.removeWhere((item) => item['provider'] == provider);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_feedsKey, jsonEncode(list));
  }

  static Future<List<Map<String, String>>> refresh() async {
    final all = <Map<String, String>>[];
    for (final feed in await feeds()) {
      final uri = Uri.tryParse(feed['url'] ?? '');
      if (uri == null || !uri.hasScheme) throw StateError('Érvénytelen iCal-link: ${feed['provider']}');
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode > 299) throw StateError('${feed['provider']}: a naptár nem érhető el.');
      final body = await utf8.decoder.bind(response).join();
      all.addAll(_parse(body, feed['provider'] ?? 'Külső naptár'));
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_eventsKey, jsonEncode(all));
    return all;
  }

  static Future<List<Map<String, String>>> events() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_eventsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Map<String, String>.from(e as Map)).toList();
  }

  static List<Map<String, String>> _parse(String content, String provider) {
    final result = <Map<String, String>>[];
    Map<String, String>? event;
    for (final line in content.replaceAll('\r\n ', '').split('\n')) {
      if (line == 'BEGIN:VEVENT') { event = <String, String>{'provider': provider}; continue; }
      if (line == 'END:VEVENT') { if (event?['start'] != null) result.add(event!); event = null; continue; }
      if (event == null) continue;
      final index = line.indexOf(':');
      if (index < 1) continue;
      final key = line.substring(0, index).split(';').first;
      final value = line.substring(index + 1);
      if (key == 'DTSTART') event['start'] = value;
      if (key == 'DTEND') event['end'] = value;
      if (key == 'SUMMARY') event['title'] = value;
      if (key == 'UID') event['uid'] = value;
    }
    return result;
  }
}
