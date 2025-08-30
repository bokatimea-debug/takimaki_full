// lib/screens/provider_add_service_screen.dart
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:table_calendar/table_calendar.dart";
import "../services/service_store.dart";

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final d = n.text.replaceAll(RegExp(r"[^0-9]"), "");
    if (d.isEmpty) return const TextEditingValue(text: "");
    final b = StringBuffer();
    for (int i=0;i<d.length;i++){
      final idx = d.length - i;
      b.write(d[i]);
      if (idx>1 && idx%3==1) b.write(" ");
    }
    final f = b.toString();
    return TextEditingValue(text: f, selection: TextSelection.collapsed(offset: f.length));
  }
}

class ProviderAddServiceScreen extends StatefulWidget {
  const ProviderAddServiceScreen({super.key});
  @override
  State<ProviderAddServiceScreen> createState() => _ProviderAddServiceScreenState();
}

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  final store = ServiceStore.instance;

  final _options = const [
    "Általános takarítás","Nagytakarítás","Felújítás utáni takarítás",
    "Karbantartás","Vízszerelés","Gázszerelés","Légkondicionáló szerelés",
    "Bútorösszeszerelés","Villanyszerelés",
  ];

  String? _service;
  final Set<String> _districts = {};
  final priceCtrl = TextEditingController();
  PriceUnit _unit = PriceUnit.ftPerHour;

  final List<ServiceSlot> _slots = [];

  @override
  void dispose() { priceCtrl.dispose(); super.dispose(); }

  Future<void> _pickDistricts() async {
    final all = [
      "I","II","III","IV","V","VI","VII","VIII","IX","X",
      "XI","XII","XIII","XIV","XV","XVI","XVII","XVIII","XIX","XX",
      "XXI","XXII","XXIII"
    ];
    final current = Set<String>.from(_districts);
    final out = await showDialog<Set<String>>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text("Budapest, kerületek"),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                FilterChip(
                  label: const Text("Mind"),
                  selected: current.length==all.length,
                  onSelected: (v){
                    setLocal((){
                      current
                        ..clear()
                        ..addAll(v?all:const <String>[]);
                    });
                  },
                ),
                ...all.map((d)=>FilterChip(
                  label: Text(d),
                  selected: current.contains(d),
                  onSelected: (v){
                    setLocal((){ v? current.add(d) : current.remove(d); });
                  },
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Mégse")),
            FilledButton(onPressed: ()=>Navigator.pop(ctx, current), child: const Text("Mentés")),
          ],
        ),
      ),
    );
    if (out!=null) setState((){ _districts..clear()..addAll(out); });
  }

  Future<void> _addMultiSlots() async {
    final selected = <DateTime>{};
    TimeOfDay? from;
    TimeOfDay? to;

    await showDialog<void>(
      context: context,
      builder: (ctx){
        DateTime focused = DateTime.now();
        DateTime first = DateTime(DateTime.now().year-1,1,1);
        DateTime last  = DateTime(DateTime.now().year+2,12,31);
        return StatefulBuilder(
          builder: (ctx, setLocal){
            Future<void> pickTimes() async {
              final f = await showTimePicker(context: ctx, initialTime: const TimeOfDay(hour: 9,minute: 0));
              if (f == null) return;
              final t = await showTimePicker(context: ctx, initialTime: const TimeOfDay(hour: 16,minute: 0));
              if (t == null) return;
              setLocal((){ from = f; to = t; });
            }
            return AlertDialog(
              title: const Text("Napok kiválasztása"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 340, height: 300,
                    child: TableCalendar(
                      firstDay: first, lastDay: last, focusedDay: focused,
                      selectedDayPredicate: (d)=> selected.any((s)=> isSameDay(s,d)),
                      onDaySelected: (d, fd){
                        setLocal((){
                          focused = d;
                          final exists = selected.any((s)=> isSameDay(s,d));
                          if (exists) {
                            selected.removeWhere((s)=> isSameDay(s,d));
                          } else {
                            selected.add(DateTime(d.year,d.month,d.day));
                          }
                        });
                      },
                      onPageChanged: (d)=> setLocal(()=> focused=d),
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(from==null||to==null ? "Idő: nincs beállítva" : "Idő: ${_tf(from!)} – ${_tf(to!)}"),
                    trailing: const Icon(Icons.schedule),
                    onTap: pickTimes,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Mégse")),
                FilledButton(
                  onPressed: (){
                    if (selected.isNotEmpty && from!=null && to!=null) {
                      Navigator.pop(ctx);
                      setState((){
                        for (final d in selected) {
                          _slots.add(ServiceSlot(date: d, from: from!, to: to!));
                        }
                      });
                    }
                  },
                  child: const Text("Hozzáadás"),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _removeSlot(int i)=> setState(()=> _slots.removeAt(i));

  void _save() {
    final priceRaw = priceCtrl.text.replaceAll(" ","");
    if (_service==null || _districts.isEmpty || priceRaw.isEmpty || _slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tölts ki mindent: szolgáltatás, kerület(ek), ár, napok/idő.")));
      return;
    }
    final s = ProviderService(
      name: _service!,
      districts: (_districts.toList()..sort()),
      price: int.tryParse(priceRaw)??0,
      unit: _unit,
      slots: List<ServiceSlot>.from(_slots),
    );
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int) {
      ServiceStore.instance.update(arg, s);
    } else {
      ServiceStore.instance.add(s);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      final e = ServiceStore.instance.services[args];
      _service ??= e.name;
      if (_districts.isEmpty) _districts.addAll(e.districts);
      if (priceCtrl.text.isEmpty) {
        final t = e.price.toString();
        final b = StringBuffer();
        for (int i=0;i<t.length;i++){
          final idx = t.length - i;
          b.write(t[i]); if (idx>1 && idx%3==1) b.write(" ");
        }
        priceCtrl.text = b.toString();
      }
      if (_slots.isEmpty) _slots.addAll(e.slots);
      _unit = e.unit;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Új szolgáltatás")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _options.map((o){
                final sel = _service==o;
                return ChoiceChip(label: Text(o), selected: sel, onSelected: (_)=> setState(()=> _service=o));
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text("Budapest, kerületek")),
                TextButton(onPressed: _pickDistricts, child: const Text("Kiválasztás")),
              ],
            ),
            Text(_districts.isEmpty ? "Nincs kiválasztva" : (_districts.toList()..sort()).join(", "),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsFormatter()],
                    decoration: const InputDecoration(labelText: "Ár", hintText: "pl. 12 000"),
                  ),
                ),
                const SizedBox(width: 8),
                ToggleButtons(
                  isSelected: [_unit==PriceUnit.ftPerHour, _unit==PriceUnit.ftPerSqm],
                  onPressed: (i)=> setState(()=> _unit = i==0? PriceUnit.ftPerHour : PriceUnit.ftPerSqm),
                  children: const [Padding(padding: EdgeInsets.symmetric(horizontal:10), child: Text("Ft/óra")),
                                   Padding(padding: EdgeInsets.symmetric(horizontal:10), child: Text("Ft/nm"))],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text("Elérhetőség (több nap + idő)")),
                TextButton(onPressed: _addMultiSlots, child: const Text("Hozzáadás")),
              ],
            ),
            if (_slots.isEmpty) const Text("Nincs idősáv megadva")
            else Wrap(
              spacing: 6, runSpacing: 6,
              children: List.generate(_slots.length, (i){
                final s = _slots[i];
                return InputChip(
                  label: Text("${_df(s.date)} • ${_tf(s.from)}–${_tf(s.to)}"),
                  onDeleted: ()=> _removeSlot(i),
                );
              }),
            ),
            const Spacer(),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text("Mentés"))),
          ],
        ),
      ),
    );
  }

  String _df(DateTime d)=> "${d.year}.${d.month.toString().padLeft(2,'0')}.${d.day.toString().padLeft(2,'0')}.";
  String _tf(TimeOfDay t)=> "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";
}
