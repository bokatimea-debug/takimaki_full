// lib/models/sanctions.dart
enum SanctionAction { none, warn, suspend14d, banPermanent }

class ProviderDisciplineState {
  int points = 0;                // súlyozott pontok (panasz/negatív értékelés)
  int oneStarCount = 0;          // 1 csillagos értékelések darabszáma (5 => felfüggesztés)
  int consecutiveNoShows = 0;    // egymás utáni no-show-k (2 => 14 nap)
  int warningsThisWeek = 0;      // heti figyelmeztetések számolása
  int suspensionsCount = 0;      // hányszor ért el 10 pontot (2. alkalom = végleges tiltás)
  DateTime? suspendedUntil;      // ha nem null => felfüggesztett eddig
  bool banned = false;           // végleges tiltás

  bool get isSuspendedNow =>
      suspendedUntil != null && DateTime.now().isBefore(suspendedUntil!);
}

class SanctionEngine {
  // egyszerű singleton
  static final SanctionEngine instance = SanctionEngine._();
  SanctionEngine._();

  final ProviderDisciplineState state = ProviderDisciplineState();

  /// Panasz érkezett (mindig automatikus figyelmeztetés + 1 pont)
  SanctionAction onComplaint() {
    state.points += 1;
    // heti 3 panasz => automatikus figyelmeztetés (itt egyszerűsítve: számláló növelés)
    state.warningsThisWeek += 1;
    if (state.warningsThisWeek >= 3) {
      // heti 3 panasz -> warn (a pont már hozzáadódott)
      return _evaluatePointsOrWarn(forceWarn: true);
    }
    return _evaluatePointsOrWarn();
  }

  /// Értékelés rögzítése (1–5)
  SanctionAction onRating(int stars) {
    if (stars <= 2) {
      // 1–2 csillag -> automatikus figyelmeztetés + 1 pont
      state.points += 1;
      if (stars == 1) state.oneStarCount += 1;
      // 5x 1 csillag => automatikus felfüggesztés (14 nap)
      if (state.oneStarCount >= 5) {
        return _suspend14Days();
      }
      return _evaluatePointsOrWarn(forceWarn: true);
    }
    // 3–5 csillag: nincs szankció
    return SanctionAction.none;
  }

  /// No-show (csak megrendelő jelzése számít)
  SanctionAction onNoShowReportedByCustomer() {
    state.consecutiveNoShows += 1;
    if (state.consecutiveNoShows >= 2) {
      state.consecutiveNoShows = 0; // reset a szankció érvényesítésekor
      return _suspend14Days();
    }
    // első no-show: azonnali figyelmeztetés + 1 pont
    state.points += 1;
    return _evaluatePointsOrWarn(forceWarn: true);
  }

  /// Heti reset (pl. hét elején meghívható CRON jelleggel)
  void weeklyReset() {
    state.warningsThisWeek = 0;
  }

  // ----- belső segédek -----

  SanctionAction _evaluatePointsOrWarn({bool forceWarn = false}) {
    // 10 pont => 14 nap felfüggesztés; másodszor 10 pont => végleges tiltás
    if (state.points >= 10) {
      state.points = 0;
      state.suspensionsCount += 1;
      if (state.suspensionsCount >= 2) {
        state.banned = true;
        return SanctionAction.banPermanent;
      }
      return _suspend14Days();
    }
    if (forceWarn) {
      return SanctionAction.warn;
    }
    // 8 pontnál NINCS értesítés (csak figyelmeztetésnél/susp/ban)
    return SanctionAction.none;
  }

  SanctionAction _suspend14Days() {
    state.suspendedUntil = DateTime.now().add(const Duration(days: 14));
    return SanctionAction.suspend14d;
  }
}

