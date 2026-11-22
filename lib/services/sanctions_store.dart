import 'package:shared_preferences/shared_preferences.dart';

class SanctionsStore {
  static const _providerNoShows = 'sanction_provider_no_shows';
  static const _providerPoints = 'sanction_provider_negative_points';
  static const _providerSuspendedUntil = 'sanction_provider_suspended_until';
  static const _providerSosSuspendedUntil =
      'sanction_provider_sos_suspended_until';
  static const _customerLateCancellations =
      'sanction_customer_late_cancellations';
  static const _customerSuspendedUntil = 'sanction_customer_suspended_until';

  static Future<DateTime?> providerSuspendedUntil() async {
    final prefs = await SharedPreferences.getInstance();
    return DateTime.tryParse(prefs.getString(_providerSuspendedUntil) ?? '');
  }

  static Future<int> customerLateCancellationCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_customerLateCancellations) ?? 0;
  }

  static Future<DateTime?> customerSuspendedUntil() async {
    final prefs = await SharedPreferences.getInstance();
    return DateTime.tryParse(prefs.getString(_customerSuspendedUntil) ?? '');
  }

  static Future<bool> isProviderSuspended() async {
    final until = await providerSuspendedUntil();
    return until != null && DateTime.now().isBefore(until);
  }

  /// SOS-munkát csak az vállalhat, akinek nincs aktív SOS-felfüggesztése.
  /// A normál szolgáltatásokhoz való hozzáférést ez nem érinti.
  static Future<DateTime?> providerSosSuspendedUntil() async {
    final prefs = await SharedPreferences.getInstance();
    return DateTime.tryParse(prefs.getString(_providerSosSuspendedUntil) ?? '');
  }

  static Future<bool> isProviderSosSuspended() async {
    final until = await providerSosSuspendedUntil();
    return until != null && DateTime.now().isBefore(until);
  }

  /// SOS-nál a megrendelői "nem jelent meg" bejelentés három hónapra
  /// felfüggeszti csak az SOS-funkció használatát. Élesben ezt a backendnek
  /// kell fiókazonosítóhoz kötve, visszaélés-védelemmel kezelnie.
  static Future<DateTime> recordProviderSosNoShow() async {
    final prefs = await SharedPreferences.getInstance();
    final until = DateTime.now().add(const Duration(days: 90));
    await prefs.setString(_providerSosSuspendedUntil, until.toIso8601String());
    return until;
  }

  static Future<bool> isCustomerSuspended() async {
    final until = await customerSuspendedUntil();
    return until != null && DateTime.now().isBefore(until);
  }

  static Future<DateTime?> recordProviderNoShow() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_providerNoShows) ?? 0) + 1;
    if (count >= 2) {
      final until = DateTime.now().add(const Duration(days: 14));
      await prefs.setInt(_providerNoShows, 0);
      await prefs.setString(_providerSuspendedUntil, until.toIso8601String());
      return until;
    }
    await prefs.setInt(_providerNoShows, count);
    return null;
  }

  static Future<DateTime?> addProviderNegativePoint() async {
    final prefs = await SharedPreferences.getInstance();
    final points = (prefs.getInt(_providerPoints) ?? 0) + 1;
    if (points >= 10) {
      final until = DateTime.now().add(const Duration(days: 14));
      await prefs.setInt(_providerPoints, 0);
      await prefs.setString(_providerSuspendedUntil, until.toIso8601String());
      return until;
    }
    await prefs.setInt(_providerPoints, points);
    return null;
  }

  static Future<DateTime?> recordCustomerLateCancellation() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_customerLateCancellations) ?? 0) + 1;
    if (count >= 3) {
      final until = DateTime.now().add(const Duration(days: 5));
      await prefs.setInt(_customerLateCancellations, 0);
      await prefs.setString(_customerSuspendedUntil, until.toIso8601String());
      return until;
    }
    await prefs.setInt(_customerLateCancellations, count);
    return null;
  }
}
