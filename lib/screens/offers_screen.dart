import 'package:flutter/material.dart';
import '../repositories/offers_repository.dart';

class OffersScreen extends StatefulWidget {
  final String requestId;
  const OffersScreen({super.key, required this.requestId});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final repo = OffersRepository.instance;

  @override
  void initState() {
    super.initState();
    repo.seedDemo(widget.requestId);
  }

  @override
  Widget build(BuildContext context) {
    final items = repo.listByRequest(widget.requestId);

    Color chipColor(OfferStatus s) {
      switch (s) {
        case OfferStatus.accepted:
          return Colors.green;
        case OfferStatus.inactive:
          return Colors.grey;
        case OfferStatus.pending:
          return Colors.orange;
      }
    }

    String chipText(OfferStatus s) {
      switch (s) {
        case OfferStatus.accepted:
          return 'Elfogadva';
        case OfferStatus.inactive:
          return 'Inaktív';
        case OfferStatus.pending:
          return 'Függőben';
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ajánlatok')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final o = items[i];
          return Card(
            child: ListTile(
              title: Text('${o.providerName}'),
              subtitle: Text('${o.priceFt} Ft'),
              trailing: Chip(
                label: Text(chipText(o.status), style: const TextStyle(color: Colors.white)),
                backgroundColor: chipColor(o.status),
              ),
              onTap: o.status == OfferStatus.pending
                  ? () {
                      setState(() => repo.accept(o.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ajánlat elfogadva. A többi inaktív lett.')),
                      );
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
