import "package:flutter/material.dart";
import "../services/service_store.dart";

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  final store = ServiceStore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltatásaim")),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: store.services.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final s = store.services[i];
          final unit = s.unit == PriceUnit.ftPerHour ? "Ft/óra" : "Ft/nm";
          return ListTile(
            title: Text(s.name),
            subtitle: Text("${s.districts.join(", ")} • ${s.price} $unit"),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _EditorRoute(),
                      settings: RouteSettings(arguments: i),
                    ),
                  ).then((_) => setState(() {})),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() => store.remove(i)),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const _EditorRoute()),
        ).then((_) => setState(() {})),
        label: const Text("Új szolgáltatás"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

/// Csak navigációs alias a szerkesztő képernyőhöz (kód a külön fájlban van).
class _EditorRoute extends StatelessWidget {
  const _EditorRoute();

  @override
  Widget build(BuildContext context) =>
      const _Forward(child: "lib/screens/provider_add_service_screen.dart not imported");
}

class _Forward extends StatelessWidget {
  const _Forward({required this.child});
  final String child;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
