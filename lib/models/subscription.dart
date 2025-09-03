class SubscriptionState {
  final bool isActive;
  final DateTime? activeUntil;
  final String role; // "provider" vagy "customer"
  final int successfulCount;

  SubscriptionState({
    required this.isActive,
    required this.role,
    required this.successfulCount,
    this.activeUntil,
  });

  bool get thresholdReached {
    if (role == 'provider') return successfulCount >= 1;
    if (role == 'customer') return successfulCount >= 3;
    return false;
  }

  bool get mustSubscribe => thresholdReached && !isActive;
}
