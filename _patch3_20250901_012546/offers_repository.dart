import 'dart:collection';

enum OfferStatus { pending, accepted, inactive }

class Offer {
  final String id;
  final String requestId; // ugyanahhoz a megrendeléshez tartozó ajánlatok
  OfferStatus status;
  final int priceFt;
  final String providerName;

  Offer({
    required this.id,
    required this.requestId,
    required this.priceFt,
    required this.providerName,
    this.status = OfferStatus.pending,
  });
}

class OffersRepository {
  OffersRepository._();
  static final instance = OffersRepository._();

  final _items = <Offer>[];

  UnmodifiableListView<Offer> listByRequest(String requestId) =>
      UnmodifiableListView(_items.where((o) => o.requestId == requestId));

  void seedDemo(String requestId) {
    if (_items.any((o) => o.requestId == requestId)) return;
    _items.addAll([
      Offer(id: 'o1', requestId: requestId, priceFt: 17000, providerName: 'Anna'),
      Offer(id: 'o2', requestId: requestId, priceFt: 18000, providerName: 'Béla'),
      Offer(id: 'o3', requestId: requestId, priceFt: 16500, providerName: 'Csaba'),
    ]);
  }

  void accept(String offerId) {
    final offer = _items.firstWhere((o) => o.id == offerId);
    offer.status = OfferStatus.accepted;
    for (final other in _items.where(
        (o) => o.requestId == offer.requestId && o.id != offer.id)) {
      other.status = OfferStatus.inactive;
    }
  }
}
