import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

/// Kedvencek – csak lokális MVP.
/// Elem: { id: String, name: String }
class FavoritesRepository {
  static const _key = "favorites_json";

  static Future<List<Map<String,dynamic>>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw==null || raw.isEmpty) return [];
    final d = jsonDecode(raw);
    if (d is List) return d.cast<Map>().map((e)=> Map<String,dynamic>.from(e)).toList();
    return [];
  }

  static Future<void> _save(List<Map<String,dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items));
  }

  static Future<bool> isFav(String id) async {
    final items = await list();
    return items.any((e)=> e["id"]==id);
  }

  static Future<void> toggle(Map<String,dynamic> item) async {
    final items = await list();
    final i = items.indexWhere((e)=> e["id"]==item["id"]);
    if (i>=0) {
      items.removeAt(i);
    } else {
      items.add({"id": item["id"].toString(), "name": (item["name"]??"").toString()});
    }
    await _save(items);
  }
}
