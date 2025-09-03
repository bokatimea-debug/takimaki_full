import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

/// Egyszerű szankció számlálók lokálisan (MVP).
/// { noShowCount: int, penaltyPoints: int, suspendedUntil: String? (YYYY-MM-DD) }
class SanctionsRepository {
  static const _key = "sanctions_json";

  static Future<Map<String,dynamic>> get() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw==null || raw.isEmpty) return {"noShowCount":0,"penaltyPoints":0,"suspendedUntil":null};
    final m = jsonDecode(raw);
    return Map<String,dynamic>.from(m);
  }

  static Future<void> save(Map<String,dynamic> m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(m));
  }

  static Future<void> addNoShow() async {
    final m = await get();
    m["noShowCount"] = (m["noShowCount"]??0)+1;
    // 2 no-show → 14 nap felfüggesztés
    if (m["noShowCount"]>=2) {
      final now = DateTime.now();
      final until = now.add(const Duration(days:14));
      m["suspendedUntil"] = "${until.year}-${until.month.toString().padLeft(2,'0')}-${until.day.toString().padLeft(2,'0')}";
      m["noShowCount"] = 0; // lenullázzuk a számlálót
    }
    await save(m);
  }

  static Future<void> addPenalty(int pts) async {
    final m = await get();
    final cur = (m["penaltyPoints"]??0) as int;
    final next = cur + pts;
    m["penaltyPoints"] = next;
    if (next>=10) {
      final now = DateTime.now();
      final until = now.add(const Duration(days:14));
      m["suspendedUntil"] = "${until.year}-${until.month.toString().padLeft(2,'0')}-${until.day.toString().padLeft(2,'0')}";
      m["penaltyPoints"] = 0;
    }
    await save(m);
  }

  static Future<bool> isSuspended() async {
    final m = await get();
    final s = (m["suspendedUntil"]??"") as String;
    if (s.isEmpty) return false;
    final parts = s.split("-");
    if (parts.length!=3) return false;
    final until = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    return DateTime.now().isBefore(until);
  }
}
