// lib/models/subscription.dart
enum UserRole { customer, provider }

class SubscriptionPolicy {
  static Duration trialFor(UserRole role) {
    return role == UserRole.customer
        ? const Duration(days: 90)   // 3 hónap
        : const Duration(days: 30);  // 1 hónap
  }

  static bool isActive({
    required UserRole role,
    required DateTime startAt,
    required bool paidActive,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final inTrial = current.isBefore(startAt.add(trialFor(role)));
    return inTrial || paidActive;
  }

  static String trialLabel(UserRole role) {
    return role == UserRole.customer ? '3 hónap próba' : '1 hónap próba';
  }
}
