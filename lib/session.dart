// lib/session.dart
import 'models/subscription.dart';

class UserSession {
  static final UserSession instance = UserSession._();
  UserSession._();

  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  bool hasPhoto = false;

  // előfizetés / szerep
  UserRole? role;                 // customer | provider
  DateTime? subscriptionStartAt;  // első szerep-választáskor állítjuk be
  bool paidActive = false;        // demó: gombbal aktiválható

  bool get isRegistered =>
      (firstName != null && firstName!.trim().isNotEmpty && hasPhoto);

  bool get hasRole => role != null;

  bool get isSubscriptionActive {
    if (role == null || subscriptionStartAt == null) return false;
    return SubscriptionPolicy.isActive(
      role: role!,
      startAt: subscriptionStartAt!,
      paidActive: paidActive,
    );
  }

  void startSubscriptionIfNeeded(UserRole r) {
    role ??= r;
    subscriptionStartAt ??= DateTime.now();
  }

  void activatePaidDemo() {
    paidActive = true;
  }

  void clear() {
    firstName = null;
    lastName = null;
    phone = null;
    email = null;
    hasPhoto = false;
    role = null;
    subscriptionStartAt = null;
    paidActive = false;
  }
}
