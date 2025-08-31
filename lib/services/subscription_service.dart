import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

enum UserRole { customer, provider }

class SubscriptionInfo {
  final bool active;
  final DateTime? trialUntil;
  final DateTime? paidUntil;
  const SubscriptionInfo({required this.active, this.trialUntil, this.paidUntil});

  Map<String, dynamic> toJson() => {
    "active": active,
    "trialUntil": trialUntil?.toIso8601String(),
    "paidUntil": paidUntil?.toIso8601String(),
  };
  static SubscriptionInfo fromJson(Map<String, dynamic> m) => SubscriptionInfo(
    active: m["active"] == true,
    trialUntil: m["trialUntil"]!=null ? DateTime.tryParse(m["trialUntil"]) : null,
    paidUntil: m["paidUntil"]!=null ? DateTime.tryParse(m["paidUntil"]) : null,
  );
}

class SubscriptionService {
  static String _key(UserRole role) => "sub_${role.name}";
  static Future<SubscriptionInfo> get(UserRole role) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key(role));
    if (raw == null) return _defaultFor(role);
    try { return SubscriptionInfo.fromJson(jsonDecode(raw)); } catch (_) { return _defaultFor(role); }
  }

  static Future<void> startTrial(UserRole role) async {
    final sp = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final trialEnd = role==UserRole.customer ? now.add(const Duration(days: 90)) : now.add(const Duration(days: 30));
    final info = SubscriptionInfo(active: true, trialUntil: trialEnd, paidUntil: null);
    await sp.setString(_key(role), jsonEncode(info.toJson()));
  }

  static Future<void> setPaid(UserRole role, DateTime until) async {
    final sp = await SharedPreferences.getInstance();
    final info = SubscriptionInfo(active: true, trialUntil: null, paidUntil: until);
    await sp.setString(_key(role), jsonEncode(info.toJson()));
  }

  static Future<void> cancel(UserRole role) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key(role));
  }

  static SubscriptionInfo _defaultFor(UserRole role) => const SubscriptionInfo(active:false);
}
