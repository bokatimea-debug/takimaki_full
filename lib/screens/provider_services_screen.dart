// lib/screens/provider_services_screen.dart
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
  void initState() {
    super.initState();
    store.addListener(_onChanged);
  }

  @override
  void dispose() {
    store.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _confirmDelete(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Szolgáltatás törlése"),
        content: const Text("Biztosan törölni szeretnéd?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Mégse")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Törlés")),
        ],
      ),
    );
    if (ok == true) {
      store.removeAt(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltatásaim")),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/provider/add_service");
                },
                child: const Text("Új szolgáltatás felvétele"),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: store.services.isEmpty
                ? const Center(child: Text("Még nincs felvett szolgáltatás."))
                : ListView.separated(
                    itemCount: store.services.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final s = store.services[i];
                      return ListTile(
                        title: Text(s.name),
                        subtitle: Text("${s.priceFormatted} ${s.unitLabel}\nBudapest: ${s.districtsLine}"),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: "Szerkesztés",
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(context, "/provider/add_service", arguments: i);
                              },
                            ),
                            IconButton(
                              tooltip: "Törlés",
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _confirmDelete(i),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
