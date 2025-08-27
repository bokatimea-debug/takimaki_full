import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../models/stats.dart';
import '../models/calendar.dart';

class OffersDemoScreen extends StatefulWidget {
  const OffersDemoScreen({super.key});

  @override
  State<OffersDemoScreen> createState() => _OffersDemoScreenState();
}

class _OffersDemoScreenState extends State<OffersDemoScreen> {
  final cal = ProviderCalendar.instance;

  final List<Offer> _offers = [
    Offer(
      id: '1',
      service: 'Általános takarítás',
      providerName: 'Kiss Anna',
      district: 'XIII.',
      date: '2025-09-01',
      time: '10:00',
      price: '12000 Ft',
    ),
    Offer(
      id: '2',
      service: 'Általános takarítás',
      providerName: 'Nagy Béla',
      district: 'XIII.',
      date: '2025-09-01',
      time: '10:00',
      price: '12500 Ft',
    ),
    Offer(
      id: '3',
      service: 'Általános takarítás',
      providerName: 'Horváth Csilla',
      district: 'XIII.',
      date: '2025-09-01',
      time: '11:30',
      price: '11800 Ft',
    ),
  ];

  // Egyszerű: minden munka 90 percnek számít
  static const int _slotMinutes = 90;

  DateTime _parseDT(Offer o) {
    // date: YYYY-MM-DD, time: HH:mm
    final partsD = o.date.split('-').map(int.parse).toList(); // [y,m,d]
    final partsT = o.time.split(':').map(int.parse).toList(); // [h,m]
    return DateTime(partsD[0], partsD[1], partsD[2], partsT[0], partsT[1]);
  }

  bool _hasConflict(Offer o) {
    return !cal.isFree(_parseDT(o), _slotMinutes);
  }

  void _acceptOffer(Offer accepted) {
    if (_hasConflict(accepted)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ütköző időpont – nem fogadható el.')),
      );
      return;
    }

    setState(() {
      for (var o in _offers) {
        if (o.id == accepted.id) {
          o.status = OfferStatus.accepted;
        } else if (o.status == OfferStatus.sent || o.status == OfferStatus.responded) {
          o.status = OfferStatus.inactive;
        }
      }
      // Foglaljuk az idősávot a kiválasztott szolgáltatóhoz (demóban globálisan)
      cal.book(_parseDT(accepted), _slotMinutes,
          '${accepted.providerName} • ${accepted.service}');

      // demó: stat növelés
      Stats.instance.incCustomer();
      Stats.instance.incProvider();
    });
  }

  Color _statusColor(OfferStatus st) {
    switch (st) {
      case OfferStatus.accepted:
        return Colors.green;
      case OfferStatus.inactive:
        return Colors.grey;
      case OfferStatus.responded:
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  String _statusLabel(OfferStatus st) {
    switch (st) {
      case OfferStatus.accepted:
        return 'Elfogadva';
      case OfferStatus.inactive:
        return 'Inaktív';
      case OfferStatus.responded:
        return 'Válaszolt';
      case OfferStatus.completed:
        return 'Teljesítve';
      case OfferStatus.cancelled:
        return 'Meghiúsult';
      default:
        return 'Kiküldve';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajánlatok demó (ütközés tiltás)')),
      body: ListView.builder(
        itemCount: _offers.length,
        itemBuilder: (context, i) {
          final offer = _offers[i];
          final conflict = _hasConflict(offer);
          final actionable = (offer.status == OfferStatus.sent ||
                              offer.status == OfferStatus.responded) &&
                              !conflict;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              title: Text('${offer.providerName} – ${offer.price}'),
              subtitle: Text(
                '${offer.date} ${offer.time} • ${offer.district} • '
                '${conflict ? "Ütközés" : _statusLabel(offer.status)}',
              ),
              trailing: actionable
                  ? ElevatedButton(
                      onPressed: () => _acceptOffer(offer),
                      child: const Text('Elfogad'),
                    )
                  : Icon(
                      conflict ? Icons.block : Icons.check_circle,
                      color: conflict ? Colors.red : _statusColor(offer.status),
                    ),
            ),
          );
        },
      ),
    );
  }
}

