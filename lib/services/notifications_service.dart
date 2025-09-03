import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime ts;
  NotificationItem({required this.id, required this.title, required this.body, DateTime? ts})
    : ts = ts ?? DateTime.now();
  Map<String, dynamic> toJson()=> {"id":id,"title":title,"body":body,"ts":ts.toIso8601String()};
  static NotificationItem fromJson(Map<String, dynamic> m)=> NotificationItem(
    id:m["id"], title:m["title"], body:m["body"], ts:DateTime.parse(m["ts"]));
}

class NotificationsService {
  static const _key = "notifications";
  static Future<List<NotificationItem>> list() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw==null) return [];
    try {
      final arr = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return arr.map(NotificationItem.fromJson).toList();
    } catch (_) { return []; }
  }
  static Future<void> push(NotificationItem n) async {
    final sp = await SharedPreferences.getInstance();
    final cur = await list();
    cur.insert(0, n);
    await sp.setString(_key, jsonEncode(cur.map((e)=>e.toJson()).toList()));
  }
  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}
