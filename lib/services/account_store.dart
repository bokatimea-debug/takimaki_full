import 'package:shared_preferences/shared_preferences.dart';

class AccountStore {
  static const _deletedPhoneKey = 'deleted_account_phone';
  static const _blockedUntilKey = 'deleted_account_blocked_until';

  static Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('registration_phone') ?? '';
    await prefs.clear();
    if (phone.isNotEmpty) {
      await prefs.setString(_deletedPhoneKey, phone);
      await prefs.setString(
        _blockedUntilKey,
        DateTime.now().add(const Duration(days: 90)).toIso8601String(),
      );
    }
  }

  static Future<DateTime?> blockedUntilFor(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_deletedPhoneKey) != phone) return null;
    final until = DateTime.tryParse(prefs.getString(_blockedUntilKey) ?? '');
    if (until == null || !DateTime.now().isBefore(until)) return null;
    return until;
  }
}
