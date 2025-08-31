// lib/screens/provider_requests_screen.dart
import "package:flutter/material.dart";
import "../services/demo_data.dart";

class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({super.key});
  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen> {
  final items = List<Map<String, String>>.from(DemoRequests.incoming);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Beérkezett ajánlatkérések")),
      body: items.isEmpty
          ? const Center(child: Text("Nincs beérkezett ajánlatkérés."))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final it = items[i];
                return ListTile(
                  title: Text("${it["customer"]} • ${it["service"]}"),
                  subtitle: Text("${it["when"]}\n${it["address"]}"),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(onPressed: (){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Elutasítva")));
                        setState(()=> items.removeAt(i));
                      }, child: const Text("Elutasítás")),
                      FilledButton(onPressed: (){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ajánlat elküldve (demó)")));
                      }, child: const Text("Ajánlat")),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
