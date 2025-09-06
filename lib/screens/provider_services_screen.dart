import "package:flutter/material.dart";

class ProviderServicesScreen extends StatelessWidget {
  const ProviderServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ÁTMENETI: dummy adatok a buildhez
    final services = [
      {"name": "Apartman takarítás", "price": 8000, "duration": 60},
      {"name": "Karbantartás", "price": 10000, "duration": 90},
      {"name": "Villanyszerelés", "price": 12000, "duration": 120},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltatásaim")),
      body: ListView.separated(
        itemCount: services.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final s = services[i];
          return ListTile(
            title: Text(s["name"].toString()),
            subtitle: Text("Ár: ${s["price"]} Ft – ${s["duration"]} perc"),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  "/provider/add_service",
                  arguments: {"initial": s},
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/provider/add_service");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
