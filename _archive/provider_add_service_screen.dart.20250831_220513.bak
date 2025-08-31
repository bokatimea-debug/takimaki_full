import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:table_calendar/table_calendar.dart";

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final d = n.text.replaceAll(RegExp(r"[^0-9]"), "");
    if (d.isEmpty) return const TextEditingValue(text: "");
    final b = StringBuffer();
    for (int i = 0; i < d.length; i++) {
      final left = d.length - i;
      b.write(d[i]);
      if (left > 1 && left % 3 == 1) b.write(" ");
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

enum PriceUnit { ftPerHour, ftPerSqm }

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  final _options = const [
    "Általános takarítás","Nagytakarítás","Felújítás utáni takarítás",
    "Karbantartás","Vízszerelés","Gázszerelés","Légkondicionáló szerelés",
    "Bútorösszeszerelés","Villanyszerelés",
  ];

  String? _service;
  final Set<String> _districts = {};
  final priceCtrl = TextEditingController();
  PriceUnit _unit = PriceUnit.ftPerHour;

  final List<_Slot> _slots = [];

  @override
  void dispose() { priceCtrl.dispose(); super.dispose(); }

  Future<void> _pickDistricts() async {
    final all = const [
      "I","II","III","IV","V","VI","VII","VIII","IX","X",
      "XI","XII","XIII","XIV","XV","XVI","XVII","XVIII","XIX","XX",
      "XXI","XXII","XXIII"
    ];
    final out = await showDialog<Set<String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DistrictDialog(all: all, selected: Set.of(_districts)),
    );
    if (out != null) setState(() { _districts..clear()..addAll(out); });
  }

  Future<void> _addMultiSlots() async {
    final res = await showDialog<_MultiDayPickResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _MultiDayPickerDialog(),
    );
    if (res == null) return;
    setState(() {
      for (final d in res.days) {
        _slots.add(_Slot(date: d, from: res.from, to: res.to));
      }
    });
  }

  void _removeSlot(int i) => setState(() => _slots.removeAt(i));

  void _save() {
    final priceRaw = priceCtrl.text.replaceAll(" ", "");
    if (_service == null || _districts.isEmpty || priceRaw.isEmpty || _slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tölts ki mindent: szolgáltatás, kerület(ek), ár, napok/idő.")));
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Új szolgáltatás")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Szolgáltatás"),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _options.map((o){
                final sel = _service == o;
                return ChoiceChip(
                  label: Text(o),
                  selected: sel,
                  onSelected: (_){ setState(()=> _service = o); },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(child: Text("Budapest, kerületek")),
                TextButton(onPressed: _pickDistricts, child: const Text("Kiválasztás")),
              ],
            ),
            Text(
              _districts.isEmpty ? "Nincs kiválasztva" : (_districts.toList()..sort()).join(", "),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
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
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal:10), child: Text("Ft/óra")),
                    Padding(padding: EdgeInsets.symmetric(horizontal:10), child: Text("Ft/nm")),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
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

class _DistrictDialog extends StatefulWidget {
  final List<String> all;
  final Set<String> selected;
  const _DistrictDialog({required this.all, required this.selected});
  @override State<_DistrictDialog> createState() => _DistrictDialogState();
}
class _DistrictDialogState extends State<_DistrictDialog> {
  late Set<String> sel;
  @override void initState(){ super.initState(); sel = Set<String>.from(widget.selected); }
  void _toggleAll(bool v) { setState(() { sel.clear(); if (v) sel.addAll(widget.all); }); }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Budapest, kerületek", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(spacing:8, runSpacing:8, children: [
              FilterChip(
                label: const Text("Mind"),
                selected: sel.length == widget.all.length,
                onSelected: (v)=> _toggleAll(v),
              ),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              width: 360,
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8,
                children: widget.all.map((d){
                  final picked = sel.contains(d);
                  return SizedBox(
                    height: 38,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: picked ? primary.withOpacity(.18) : null,
                        side: BorderSide(color: picked ? primary : Colors.grey.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: (){ setState((){ picked ? sel.remove(d) : sel.add(d); }); },
                      child: Text(d, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: picked ? primary : null)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Mégse")),
                const SizedBox(width: 8),
                FilledButton(onPressed: ()=> Navigator.pop(context, sel), child: const Text("Mentés")),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _MultiDayPickResult {
  _MultiDayPickResult(this.days, this.from, this.to);
  final Set<DateTime> days;
  final TimeOfDay from;
  final TimeOfDay to;
}
class _MultiDayPickerDialog extends StatefulWidget {
  const _MultiDayPickerDialog({super.key});
  @override State<_MultiDayPickerDialog> createState() => _MultiDayPickerDialogState();
}
class _MultiDayPickerDialogState extends State<_MultiDayPickerDialog> {
  DateTime focused = DateTime.now();
  final Set<DateTime> selected = {};
  TimeOfDay? from, to;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Napok kiválasztása"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 340, height: 300,
            child: TableCalendar(
              firstDay: DateTime(DateTime.now().year-1,1,1),
              lastDay:  DateTime(DateTime.now().year+2,12,31),
              focusedDay: focused,
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              selectedDayPredicate: (d)=> selected.any((s)=> isSameDay(s, d)),
              onDaySelected: (d, _) {
                setState(() {
                  final exists = selected.any((s)=> isSameDay(s, d));
                  if (exists) { selected.removeWhere((s)=> isSameDay(s, d)); }
                  else { selected.add(DateTime(d.year, d.month, d.day)); }
                });
              },
              onPageChanged: (d)=> setState(()=> focused = d),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(from==null || to==null ? "Idő: nincs beállítva" : "Idő: ${_tf(from!)} – ${_tf(to!)}"),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final f = await showTimePicker(context: context, initialTime: from ?? const TimeOfDay(hour: 9, minute: 0), initialEntryMode: TimePickerEntryMode.dial);
              if (f == null) return;
              final t = await showTimePicker(context: context, initialTime: to ?? const TimeOfDay(hour: 16, minute: 0), initialEntryMode: TimePickerEntryMode.dial);
              if (t == null) return;
              setState(() { from = f; to = t; });
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Mégse")),
        FilledButton(
          onPressed: (selected.isEmpty || from==null || to==null) ? null : ()=> Navigator.pop(context, _MultiDayPickResult(selected, from!, to!)),
          child: const Text("Hozzáadás"),
        )
      ],
    );
  }
  String _tf(TimeOfDay t)=> "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";
}

class _Slot {
  final DateTime date;
  final TimeOfDay from;
  final TimeOfDay to;
  _Slot({required this.date, required this.from, required this.to});
}
