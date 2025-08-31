import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

class FavoriteService {
  static const _key = "favorites";
  static Future<List<String>> list() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw==null) return [];
    try { return (jsonDecode(raw) as List).cast<String>(); } catch (_) { return []; }
  }
  static Future<void> toggle(String providerId) async {
    final sp = await SharedPreferences.getInstance();
    final cur = await list();
    if (cur.contains(providerId)) {
      cur.remove(providerId);
    } else {
      cur.add(providerId);
    }
    await sp.setString(_key, jsonEncode(cur));
  }
  static Future<bool> isFav(String providerId) async {
    final cur = await list();
    return cur.contains(providerId);
  }
}
