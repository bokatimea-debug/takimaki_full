import "package:flutter/material.dart";

/// Egy szolgáltatási bejegyzés a szolgáltató oldalán.
class ProviderService {
  ProviderService({
    required this.name,
    required this.districts,
    required this.price,
    required this.unit,
    required this.slots,
  });

  String name;
  List<String> districts; // pl. ["VII","XIII"]
  int price;
  PriceUnit unit;
  List<ServiceSlot> slots;
}

enum PriceUnit { ftPerHour, ftPerSqm }

class ServiceSlot {
  ServiceSlot({
    required this.date,
    required this.from,
    required this.to,
  });

  final DateTime date;
  final TimeOfDay from;
  final TimeOfDay to;
}

/// Egyszerű, memóriában élő szolgáltatás-tároló.
class ServiceStore {
  ServiceStore._();
  static final ServiceStore instance = ServiceStore._();

  final List<ProviderService> services = [];

  void add(ProviderService s) => services.add(s);

  void update(int index, ProviderService s) {
    if (index >= 0 && index < services.length) services[index] = s;
  }

  void remove(int index) {
    if (index >= 0 && index < services.length) services.removeAt(index);
  }
}
