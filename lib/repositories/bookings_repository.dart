import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

class BookingsRepository {
  static const _key = "bookings_json";

  static Future<List<Map<String,dynamic>>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw==null || raw.isEmpty) return [];
    final d = jsonDecode(raw);
    if (d is List) {
      return d.cast<Map>().map((e)=> Map<String,dynamic>.from(e)).toList();
    }
    return [];
  }

  static Future<void> saveAll(List<Map<String,dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items));
  }

  static Future<void> add(Map<String,dynamic> booking) async {
    final items = await list();
    items.add(booking);
    await saveAll(items);
  }

  static Future<void> update(String id, Map<String,dynamic> patch) async {
    final items = await list();
    final i = items.indexWhere((e)=> e["id"]==id);
    if (i>=0) { items[i] = {...items[i], ...patch}; await saveAll(items); }
  }
}
