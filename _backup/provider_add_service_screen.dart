import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ProviderAddServiceScreen extends StatefulWidget {
  const ProviderAddServiceScreen({super.key});
  @override
  State<ProviderAddServiceScreen> createState() => _ProviderAddServiceScreenState();
}

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  final _districts = <String>{};

  final _allDistricts = const [
    "I","II","III","IV","V","VI","VII","VIII","IX","X",
    "XI","XII","XIII","XIV","XV","XVI","XVII","XVIII","XIX","XX",
    "XXI","XXII","XXIII"
  ];

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList("provider_service_districts", _districts.toList());
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Új szolgáltatás")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Budapest, kerületek", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _allDistricts.map((d) {
                final sel = _districts.contains(d);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (sel) {
                        _districts.remove(d);
                      } else {
                        _districts.add(d);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
                      border: Border.all(color: sel ? Theme.of(context).colorScheme.primary : Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      d,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: sel ? Theme.of(context).colorScheme.primary : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text("Mentés"))),
          ],
        ),
      ),
    );
  }
}
