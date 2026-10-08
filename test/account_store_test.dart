import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takimaki_full/services/account_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({
        'registration_phone': '+36 30 222 2023',
        'customer_first_name': 'Tímea',
        'provider_first_name': 'Tímea',
        'customer_bio': 'Bemutatkozás',
        'provider_services': '[{"name":"Takarítás"}]',
      }));

  for (final dates in [
    (DateTime(2027, 1, 31, 10, 20), DateTime(2027, 4, 30, 10, 20)),
    (DateTime(2027, 11, 30, 10, 20), DateTime(2028, 2, 29, 10, 20)),
    (DateTime(2026, 12, 31, 10, 20), DateTime(2027, 3, 31, 10, 20)),
  ]) {
    test('deletion blocks three calendar months from ${dates.$1}', () async {
      await AccountStore.deleteAccount(now: dates.$1);
      final until =
          await AccountStore.blockedUntilFor('+36302222023', now: dates.$1);
      expect(until, dates.$2);
      final prefs = await SharedPreferences.getInstance();
      for (final key in [
        'registration_phone',
        'customer_first_name',
        'provider_first_name',
        'customer_bio',
        'provider_services'
      ]) {
        expect(prefs.containsKey(key), isFalse,
            reason: '$key must be deleted.');
      }
      expect(prefs.containsKey('account_deleted_at'), isTrue);
      expect(await AccountStore.enforceDeletedState(now: dates.$1), isTrue);
    });
  }

  test('phone formatting cannot bypass a deletion block', () async {
    final now = DateTime(2026, 10, 3, 12);
    await AccountStore.deleteAccount(now: now);
    for (final phone in [
      '+36302222023',
      '+36 30 222 2023',
      '+36 (30) 222-2023',
      '0036302222023',
      '06302222023'
    ]) {
      expect(await AccountStore.blockedUntilFor(phone, now: now), isNotNull,
          reason: phone);
    }
    expect(
        await AccountStore.blockedUntilFor('+36301234567', now: now), isNull);
  });

  test('deleted account cannot be reopened from retained session data', () async {
    final now = DateTime(2026, 10, 6, 22);
    await AccountStore.deleteAccount(now: now);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('session_active', true);
    await prefs.setBool('registration_complete', true);
    await prefs.setString('active_role', 'customer');
    expect(await AccountStore.enforceDeletedState(now: now), isTrue);
    expect(prefs.containsKey('session_active'), isFalse);
    expect(prefs.containsKey('registration_complete'), isFalse);
    expect(prefs.containsKey('active_role'), isFalse);
  });

  test(
      'repeated deletion without an active account preserves the original block',
      () async {
    final now = DateTime(2026, 10, 3, 12);
    await AccountStore.deleteAccount(now: now);
    final before = await AccountStore.blockedUntilFor('+36302222023', now: now);
    await AccountStore.deleteAccount(now: now.add(const Duration(days: 2)));
    expect(
        await AccountStore.blockedUntilFor('+36302222023', now: now), before);
  });

  test('registration is allowed when the full three month block expires',
      () async {
    final now = DateTime(2026, 10, 3, 12);
    final expiry = DateTime(2027, 1, 3, 12);
    await AccountStore.deleteAccount(now: now);
    expect(
        await AccountStore.blockedUntilFor('+36302222023',
            now: expiry.subtract(const Duration(seconds: 1))),
        expiry);
    expect(await AccountStore.blockedUntilFor('+36302222023', now: expiry),
        isNull);
  });

  test(
      'existing deletion records remain effective after migration and repeated deletion',
      () async {
    final now = DateTime(2026, 10, 3, 12);
    final expiry = DateTime(2026, 12, 25, 12);
    SharedPreferences.setMockInitialValues({
      'deleted_account_phone': '+36 30 222 2023',
      'deleted_account_blocked_until': expiry.toIso8601String(),
    });
    expect(
        await AccountStore.blockedUntilFor('+36302222023', now: now), expiry);
    await AccountStore.deleteAccount(now: now);
    expect(
        await AccountStore.blockedUntilFor('+36302222023', now: now), expiry);
  });
}
