import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Egyszerű lokális tárolás a szolgáltatásokhoz (provider oldal).
/// Kulcs: provider_services_json
class ProviderServicesRepository {
  static const _key = 'provider_services_json';

  /// Elem struktúra:
  /// { id: String, title: String, pricingType: 'hour'|'sqm', price: int, districts: List<int>,
  ///   dates: List<String: 'YYYY-MM-DD'] }
  static Future<List<Map<String, dynamic>>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  static Future<void> saveAll(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items));
  }

  static Future<void> add(Map<String, dynamic> item) async {
    final list0 = await list();
    list0.add(item);
    await saveAll(list0);
  }

  static Future<void> remove(String id) async {
    final list0 = await list();
    list0.removeWhere((e) => e['id'] == id);
    await saveAll(list0);
  }

  static Future<void> update(String id, Map<String, dynamic> patch) async {
    final list0 = await list();
    final idx = list0.indexWhere((e) => e['id'] == id);
    if (idx >= 0) {
      list0[idx] = {...list0[idx], ...patch};
      await saveAll(list0);
    }
  }
}
