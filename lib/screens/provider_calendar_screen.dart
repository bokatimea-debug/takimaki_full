import "package:flutter/material.dart";
import "package:table_calendar/table_calendar.dart";

class ProviderCalendarScreen extends StatefulWidget {
  const ProviderCalendarScreen({super.key});
  @override
  State<ProviderCalendarScreen> createState() => _ProviderCalendarScreenState();
}

class _ProviderCalendarScreenState extends State<ProviderCalendarScreen> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _selectedDays = {};

  TimeOfDay? from;
  TimeOfDay? to;

  void _pickTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          from = picked;
        } else {
          to = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Elérhetőség beállítása")),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: _format,
            selectedDayPredicate: (day) =>
                _selectedDays.any((d) => isSameDay(d, day)),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_selectedDays.contains(selectedDay)) {
                  _selectedDays.remove(selectedDay);
                } else {
                  _selectedDays.add(selectedDay);
                }
                _focusedDay = focusedDay;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(from != null ? "Tól: ${from!.format(context)}" : "Válassz kezdést"),
              Text(to != null ? "Ig: ${to!.format(context)}" : "Válassz véget"),
            ],
          ),
          ElevatedButton(
            onPressed: () => _pickTime(true),
            child: const Text("Kezdés"),
          ),
          ElevatedButton(
            onPressed: () => _pickTime(false),
            child: const Text("Befejezés"),
          ),
        ],
      ),
    );
  }
}
