// lib/models/subscription.dart
enum UserRole { customer, provider }

class SubscriptionPolicy {
  static Duration trialFor(UserRole role) => const Duration(days: 90);

  static bool isActive({
    required UserRole role,
    required DateTime startAt,
    required bool paidActive,
    bool providerHasAcceptedFirstOrder = false,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    if (role == UserRole.provider) {
      return !providerHasAcceptedFirstOrder || paidActive;
    }
    return current.isBefore(startAt.add(trialFor(role))) || paidActive;
  }

  static String trialLabel(UserRole role) {
    return role == UserRole.customer
        ? '3 hónap ingyenes'
        : 'Az első elfogadott megrendelésig ingyenes';
  }
}
