import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

class SanctionState {
  int negativePoints;
  int noShows;
  DateTime? suspendedUntil;
  SanctionState({this.negativePoints=0, this.noShows=0, this.suspendedUntil});

  Map<String, dynamic> toJson()=> {
    "negativePoints": negativePoints,
    "noShows": noShows,
    "suspendedUntil": suspendedUntil?.toIso8601String(),
  };
  static SanctionState fromJson(Map<String, dynamic> m)=> SanctionState(
    negativePoints: (m["negativePoints"]??0) as int,
    noShows: (m["noShows"]??0) as int,
    suspendedUntil: m["suspendedUntil"]!=null ? DateTime.tryParse(m["suspendedUntil"]) : null,
  );
}

class SanctionsService {
  static const _key = "sanctions_state";
  static Future<SanctionState> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw==null) return SanctionState();
    try { return SanctionState.fromJson(jsonDecode(raw)); } catch (_) { return SanctionState(); }
  }
  static Future<void> save(SanctionState s) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(s.toJson()));
  }

  // Események:
  static Future<void> addLowRating(int stars) async {
    final s = await load();
    if (stars<=2) s.negativePoints += 2; // példa
    await _applyRules(s);
  }
  static Future<void> addComplaint() async {
    final s = await load();
    s.negativePoints += 2;
    await _applyRules(s);
  }
  static Future<void> addNoShow() async {
    final s = await load();
    s.noShows += 1;
    if (s.noShows>=2) {
      s.suspendedUntil = DateTime.now().add(const Duration(days:14));
      s.noShows = 0; // reset a büntetés után
    }
    await _applyRules(s);
  }

  static Future<void> _applyRules(SanctionState s) async {
    if (s.negativePoints>=10) {
      s.suspendedUntil = DateTime.now().add(const Duration(days:14));
      s.negativePoints = 0;
    }
    await save(s);
  }

  static Future<bool> isSuspended() async {
    final s = await load();
    final now = DateTime.now();
    if (s.suspendedUntil==null) return false;
    return now.isBefore(s.suspendedUntil!);
  }
}
