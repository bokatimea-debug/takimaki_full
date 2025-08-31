import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ProviderCalendarScreen extends StatefulWidget {
  const ProviderCalendarScreen({super.key});
  @override
  State<ProviderCalendarScreen> createState() => _ProviderCalendarScreenState();
}

class _ProviderCalendarScreenState extends State<ProviderCalendarScreen> {
  final _selected = <DateTime>{};

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(
      "provider_calendar_days",
      _selected.map((d) => "${d.year}-${d.month}-${d.day}").toList(),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final last = DateTime(now.year, now.month + 1, 0);

    return Scaffold(
      appBar: AppBar(title: const Text("Napok kiválasztása")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 4, mainAxisSpacing: 4),
          itemCount: last.day,
          itemBuilder: (_, i) {
            final d = DateTime(first.year, first.month, i + 1);
            final sel = _selected.any((x) => x.year == d.year && x.month == d.month && x.day == d.day);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (sel) {
                    _selected.removeWhere((x) => x.year == d.year && x.month == d.month && x.day == d.day);
                  } else {
                    _selected.add(d);
                  }
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : null,
                  border: Border.all(color: sel ? Theme.of(context).colorScheme.primary : Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("${i + 1}", style: TextStyle(color: sel ? Theme.of(context).colorScheme.primary : Colors.black87)),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _save, icon: const Icon(Icons.check), label: const Text("Mentés")),
    );
  }
}
