// lib/models/stats.dart
class Stats {
  static final Stats instance = Stats._();
  Stats._();

  int customerSuccessCount = 7;   // demó kiinduló érték
  int providerSuccessCount = 12;  // demó kiinduló érték

  void incCustomer() => customerSuccessCount++;
  void incProvider() => providerSuccessCount++;
}
