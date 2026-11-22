import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_backend.dart';

class RentalCalendarSync {
  static const _feedsKey = 'rental_ical_feeds';
  static const _eventsKey = 'rental_ical_events';

  static Future<List<Map<String, String>>> feeds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_feedsKey);
    final local = raw == null ? <Map<String, String>>[] : (jsonDecode(raw) as List).map((e) => Map<String, String>.from(e as Map)).toList();
    final backend = FirebaseBackend.instance;
    if (!backend.isAvailable || backend.uid == null) return local;
    try {
      final remote = await backend.firestore.collection('users').doc(backend.uid).get();
      final remoteFeeds = remote.data()?['rental_ical_feeds'];
      if (remoteFeeds is! List) return local;
      final feeds = remoteFeeds.map((e) => Map<String, String>.from(e as Map)).toList();
      await prefs.setString(_feedsKey, jsonEncode(feeds));
      return feeds;
    } catch (_) { return local; }
  }

  static Future<void> saveFeed(String provider, String url) async {
    final list = await feeds();
    list.removeWhere((item) => item['provider'] == provider);
    list.add({'provider': provider, 'url': url.trim()});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_feedsKey, jsonEncode(list));
    await _syncFeeds(list);
  }

  static Future<void> removeFeed(String provider) async {
    final list = await feeds();
    list.removeWhere((item) => item['provider'] == provider);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_feedsKey, jsonEncode(list));
    await _syncFeeds(list);
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
    final backend = FirebaseBackend.instance;
    if (backend.isAvailable && backend.uid != null) {
      try { await backend.firestore.collection('users').doc(backend.uid).set({
        'rental_ical_events': all,
        'rental_ical_refreshed_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true)); } catch (_) {}
    }
    return all;
  }

  static Future<void> _syncFeeds(List<Map<String, String>> list) async {
    final backend = FirebaseBackend.instance;
    if (!backend.isAvailable || backend.uid == null) return;
    try { await backend.firestore.collection('users').doc(backend.uid).set({
      'rental_ical_feeds': list,
      'rental_ical_updated_at': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true)); } catch (_) {}
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
