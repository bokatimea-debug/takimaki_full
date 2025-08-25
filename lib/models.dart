import 'package:intl/intl.dart';
enum UserRole { customer, provider }
class ProviderProfile {
  final String id; final String name; final List<String> services; final List<int> districts; final bool allBudapest;
  final double ratingAvg; final int ratingCount; final Duration avgResponse; final int negativePoints; final int consecutiveNoShows; final int oneStarCount;
  const ProviderProfile({required this.id, required this.name, required this.services, required this.districts, required this.allBudapest,
    required this.ratingAvg, required this.ratingCount, required this.avgResponse, this.negativePoints=0, this.consecutiveNoShows=0, this.oneStarCount=0});
  bool get isSuspended => _suspensionReason()!=null;
  String? _suspensionReason(){ if(consecutiveNoShows>=2) return "2 egymást követő no-show → 14 nap felfüggesztés";
    if(oneStarCount>=5) return "5 darab 1★ értékelés után automatikus felfüggesztés"; if(negativePoints>=10) return "10 negatív pont → 14 nap felfüggesztés"; return null; }
}
class OfferRequest { final String serviceId; final int district; final String street; final DateTime startAt;
  const OfferRequest({required this.serviceId, required this.district, required this.street, required this.startAt});
  String get formattedTime => DateFormat('yyyy.MM.dd HH:mm').format(startAt);
}
class CandidateOffer { final ProviderProfile provider; final int priceHuf; final String message;
  const CandidateOffer({required this.provider, required this.priceHuf, required this.message});
}
