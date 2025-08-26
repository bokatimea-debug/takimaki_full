// lib/models/offer.dart

enum OfferStatus {
  sent,       // kiküldve
  responded,  // szolgáltató adott árat
  accepted,   // megrendelő elfogadta
  inactive,   // másik ajánlat elfogadva
  completed,  // teljesítve
  cancelled   // meghiúsult
}

class Offer {
  final String id;
  final String service;
  final String providerName;
  final String district;
  final String date;
  final String time;
  String price;
  OfferStatus status;

  Offer({
    required this.id,
    required this.service,
    required this.providerName,
    required this.district,
    required this.date,
    required this.time,
    required this.price,
    this.status = OfferStatus.sent,
  });
}
