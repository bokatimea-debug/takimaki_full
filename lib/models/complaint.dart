// lib/models/complaint.dart
class Complaint {
  final String id;
  final String providerName;
  final String customerName;
  final String reason;
  final DateTime at;

  Complaint({
    required this.id,
    required this.providerName,
    required this.customerName,
    required this.reason,
    required this.at,
  });
}

class ComplaintStore {
  static final ComplaintStore instance = ComplaintStore._();
  ComplaintStore._();

  final List<Complaint> _items = [];

  List<Complaint> get all => List.unmodifiable(_items);

  void add({
    required String providerName,
    required String customerName,
    required String reason,
  }) {
    _items.add(Complaint(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      providerName: providerName,
      customerName: customerName,
      reason: reason,
      at: DateTime.now(),
    ));
  }

  void seedIfEmpty() {
    if (_items.isNotEmpty) return;
    add(providerName: 'Kiss Anna', customerName: 'Józsi', reason: 'Késés 30 perc');
    add(providerName: 'Nagy Béla', customerName: 'Erika', reason: 'Nem jelent meg');
    add(providerName: 'Horváth Csilla', customerName: 'Laci', reason: 'Minőségi kifogás');
  }
}
