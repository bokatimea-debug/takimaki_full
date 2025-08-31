import "package:flutter/material.dart";

class CustomerOffersScreen extends StatefulWidget {
  const CustomerOffersScreen({super.key});
  @override
  State<CustomerOffersScreen> createState() => _CustomerOffersScreenState();
}

class _CustomerOffersScreenState extends State<CustomerOffersScreen> {
  List<Map<String, dynamic>> offers = [
    {"id": "1", "provider": "Kovács Béla", "price": 15000, "note": "Gyors és pontos"},
    {"id": "2", "provider": "Szabó Anna", "price": 12000, "note": "Tapasztalt takarító"},
  ];

  void _acceptOffer(Map<String, dynamic> offer) {
    // TODO: Firestore booking mentés
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ajánlat elfogadva: ${offer["provider"]} - ${offer["price"]} Ft")),
    );
    setState(() {
      offers.removeWhere((o) => o["id"] == offer["id"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajánlataim")),
      body: ListView(
        children: offers.map((o) {
          return Card(
            child: ListTile(
              title: Text("${o["provider"]} - ${o["price"]} Ft"),
              subtitle: Text(o["note"]),
              trailing: ElevatedButton(
                onPressed: () => _acceptOffer(o),
                child: const Text("Elfogadom"),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
