import "package:flutter/material.dart";
import "../repositories/provider_services_repository.dart";

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});
  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  List<Map<String,dynamic>> _items = [];
  bool _loading = true;

  Future<void> _load() async {
    final list = await ProviderServicesRepository.list();
    if (!mounted) return;
    setState(()=> {_items = list, _loading = false});
  }

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _remove(String id) async {
    await ProviderServicesRepository.remove(id);
    await _load();
  }

  Widget _tile(Map<String,dynamic> e) {
    final title = (e["title"]??"").toString();
    final type  = (e["pricingType"]??"hour").toString() == "sqm" ? "Ft/nm" : "Ft/óra";
    final price = (e["price"]??0) as int;
    final districts = (e["districts"]??[]).join(", ");
    final dates = ((e["dates"]??[]) as List).cast<String>();
    final when = dates.isEmpty ? "—" : dates.take(3).join(", ") + (dates.length>3 ? " …" : "");

    return Card(
      child: ListTile(
        title: Text("$title  •  ${price.toString()} $type"),
        subtitle: Text("Kerületek: $districts\nNapok: $when"),
        isThreeLine: true,
        trailing: Wrap(spacing: 8, children: [
          IconButton(
            tooltip: "Szerkesztés",
            onPressed: (){
              Navigator.pushNamed(context, "/provider/add_service", arguments: {"edit": true, "item": e})
                .then((_)=> _load());
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: "Törlés",
            onPressed: ()=> _remove((e["id"]??"").toString()),
            icon: const Icon(Icons.close),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Szolgáltatásaim")),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, "/provider/add_service").then((_)=> _load());
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : (_items.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 48),
                    const SizedBox(height: 8),
                    const Text("Még nincs felvett szolgáltatásod."),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: (){
                      Navigator.pushNamed(context, "/provider/add_service").then((_)=> _load());
                    }, child: const Text("Új szolgáltatás hozzáadása"))
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                itemBuilder: (_,i)=> _tile(_items[i]),
              )
          ),
    );
  }
}
