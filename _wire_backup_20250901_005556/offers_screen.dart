import "package:flutter/material.dart";
import "../data/mock_data.dart";

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});
  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  late List<MockOffer> _items;

  @override
  void initState() {
    super.initState();
    _items = List<MockOffer>.from(MockData.offers);
  }

  void _accept(MockOffer o) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Elfogadva: ${o.providerName} • ${o.service} • ${ft(o.priceFt)}")),
    );
    setState(() => _items.removeWhere((e) => e.id == o.id));
  }

  void _reject(MockOffer o) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Elutasítva: ${o.providerName} • ${o.service}")),
    );
    setState(() => _items.removeWhere((e) => e.id == o.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Beérkezett ajánlatok")),
      body: _items.isEmpty
          ? const Center(child: Text("Nincs beérkezett ajánlat"))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final o = _items[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_offer),
                    title: Text("${o.service} • ${ft(o.priceFt)}"),
                    subtitle: Text("Szolgáltató: ${o.providerName}\nIdőpont: ${dt(context, o.dateTime)} • ${o.district}. ker."),
                    isThreeLine: true,
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(onPressed: () => _reject(o), icon: const Icon(Icons.close, color: Colors.red), tooltip: "Elutasítás"),
                        IconButton(onPressed: () => _accept(o), icon: const Icon(Icons.check_circle, color: Colors.green), tooltip: "Elfogadás"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
