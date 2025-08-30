// lib/services/service_store.dart
import "package:flutter/material.dart";

enum PriceUnit { ftPerHour, ftPerSqm }

class ServiceSlot {
  final DateTime date; // csak nap pontosság
  final TimeOfDay from;
  final TimeOfDay to;

  ServiceSlot({required this.date, required this.from, required this.to});
}

class ProviderService {
  String name;
  List<String> districts; // pl. ["I", "II", ...]
  int price; // nettó szám, pl. 12000
  PriceUnit unit;
  List<ServiceSlot> slots;

  ProviderService({
    required this.name,
    required this.districts,
    required this.price,
    required this.unit,
    required this.slots,
  });

  String get unitLabel => unit == PriceUnit.ftPerHour ? "Ft/óra" : "Ft/nm";

  String get priceFormatted {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(" ");
    }
    return buf.toString();
  }

  String get districtsLine =>
      districts.isEmpty ? "Nincs kerület megadva" : districts.join(", ");

  String get summary => "$name • ${priceFormatted} $unitLabel • Budapest: $districtsLine";
}

class ServiceStore extends ChangeNotifier {
  static final ServiceStore instance = ServiceStore._();
  ServiceStore._();

  final List<ProviderService> _services = [];

  List<ProviderService> get services => List.unmodifiable(_services);

  void add(ProviderService s) {
    _services.add(s);
    notifyListeners();
  }

  void update(int index, ProviderService s) {
    if (index >= 0 && index < _services.length) {
      _services[index] = s;
      notifyListeners();
    }
  }

  void removeAt(int index) {
    if (index >= 0 && index < _services.length) {
      _services.removeAt(index);
      notifyListeners();
    }
  }
}
