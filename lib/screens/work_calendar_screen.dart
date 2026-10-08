import 'package:flutter/material.dart';

import '../services/local_marketplace_store.dart';
import '../theme.dart';
import '../utils/work_schedule.dart';
import '../widgets/taki_app_bar.dart';

class WorkCalendarScreen extends StatefulWidget {
  const WorkCalendarScreen({super.key});
  @override
  State<WorkCalendarScreen> createState() => _WorkCalendarScreenState();
}

class _WorkCalendarScreenState extends State<WorkCalendarScreen> {
  DateTime _day = DateUtils.dateOnly(DateTime.now());
  bool _week = false;
  String _role = 'customer';
  List<Map<String, dynamic>> _works = [];
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _role = ModalRoute.of(context)?.settings.arguments == 'provider' ? 'provider' : 'customer';
    _load();
  }

  Future<void> _load() async {
    final works = _role == 'provider'
        ? await LocalMarketplaceStore.providerOrders()
        : await LocalMarketplaceStore.customerOrders();
    if (!mounted) return;
    setState(() => _works = works
        .where((w) => WorkSchedule.active(w) || w['status'] == 'Teljesítve')
        .toList());
  }

  int _count(DateTime day) => _works.where((w) => DateUtils.isSameDay(WorkSchedule.start(w), day)).length;
  Color _dayColor(int weekday) {
    if (weekday >= DateTime.saturday) return takiYellowSoft;
    return weekday.isEven ? takiMint : takiCream;
  }
  String _two(int value) => value.toString().padLeft(2, '0');
  String _monthName(int month) => const [
        'január',
        'február',
        'március',
        'április',
        'május',
        'június',
        'július',
        'augusztus',
        'szeptember',
        'október',
        'november',
        'december',
      ][month - 1];

  void _changeMonth(int delta) {
    final target = DateTime(_day.year, _day.month + delta, 1);
    final last = DateTime(target.year, target.month + 1, 0).day;
    setState(() => _day = DateTime(
          target.year,
          target.month,
          _day.day.clamp(1, last).toInt(),
        ));
  }

  Widget _monthGrid() {
    final first = DateTime(_day.year, _day.month, 1);
    final days = DateTime(_day.year, _day.month + 1, 0).day;
    final leading = first.weekday - 1;
    final cells = ((leading + days + 6) ~/ 7) * 7;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: .94), takiMint],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: takiTealDark.withValues(alpha: .09),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Előző hónap',
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${_day.year}. ${_monthName(_day.month)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: takiTealDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Következő hónap',
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          Row(
            children: [
              for (final name in const ['H', 'K', 'Sze', 'Cs', 'P', 'Szo', 'V'])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: takiMutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: .92,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final number = index - leading + 1;
              if (number < 1 || number > days) return const SizedBox.shrink();
              final date = DateTime(_day.year, _day.month, number);
              final selected = DateUtils.isSameDay(date, _day);
              final today = DateUtils.isSameDay(date, DateTime.now());
              final count = _count(date);
              return InkWell(
                key: ValueKey('month-day-$number'),
                borderRadius: BorderRadius.circular(15),
                onTap: () => setState(() => _day = date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: selected
                        ? takiTeal
                        : (today ? takiYellowSoft : _dayColor(date.weekday)),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selected
                          ? takiTeal
                          : (today ? takiOrange : Colors.white),
                      width: today && !selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$number',
                        style: TextStyle(
                          color: selected ? Colors.white : takiTealDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: count > 0 ? 20 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: count > 0
                              ? takiOrange
                              : (selected ? Colors.white54 : Colors.transparent),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 6,
                decoration: BoxDecoration(
                  color: takiOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Elfogadott munka',
                style: TextStyle(color: takiMutedText, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monday = _day.subtract(Duration(days: _day.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final items = _works.where((w) => DateUtils.isSameDay(WorkSchedule.start(w), _day)).toList()
      ..sort((a, b) => WorkSchedule.start(a)!.compareTo(WorkSchedule.start(b)!));
    return Scaffold(
      appBar: TakiAppBar(title: const Text('Naptár')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            SegmentedButton<bool>(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? takiOrange
                      : takiMint,
                ),
                foregroundColor: WidgetStateProperty.all(takiTealDark),
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontWeight: FontWeight.w900),
                ),
                side: WidgetStateProperty.all(
                  const BorderSide(color: takiTealDark, width: 1.2),
                ),
              ),
              segments: const [
                ButtonSegment(value: false, label: Text('Havi nézet')),
                ButtonSegment(value: true, label: Text('Heti nézet')),
              ],
              selected: {_week},
              onSelectionChanged: (v) => setState(() => _week = v.single),
            ),
            const SizedBox(height: 14),
            if (!_week) _monthGrid(),
            if (_week)
              Container(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white.withValues(alpha: .94), takiMint],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: takiTealDark.withValues(alpha: .09), blurRadius: 18, offset: const Offset(0, 7))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Előző hét',
                          onPressed: () => setState(() => _day = _day.subtract(const Duration(days: 7))),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: Text(
                            '${monday.year}. ${_two(monday.month)}. ${_two(monday.day)}. – ${_two(sunday.month)}. ${_two(sunday.day)}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: takiTealDark, fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Következő hét',
                          onPressed: () => setState(() => _day = _day.add(const Duration(days: 7))),
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 92,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        itemCount: 7,
                        separatorBuilder: (_, __) => const SizedBox(width: 7),
                        itemBuilder: (context, i) {
                          final day = monday.add(Duration(days: i));
                          final selected = DateUtils.isSameDay(day, _day);
                          final count = _count(day);
                          return InkWell(
                            key: ValueKey('week-day-$i'),
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => setState(() => _day = day),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 58,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? takiTeal : _dayColor(day.weekday),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: selected ? takiTeal : const Color(0xFFD4DFDC)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    const ['H', 'K', 'Sze', 'Cs', 'P', 'Szo', 'V'][i],
                                    style: TextStyle(color: selected ? Colors.white : takiMutedText, fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${day.day}', style: TextStyle(color: selected ? Colors.white : takiTealDark, fontWeight: FontWeight.w900, fontSize: 24)),
                                  const Spacer(),
                                  Container(
                                    width: count > 0 ? 24 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: count > 0 ? takiOrange : (selected ? Colors.white54 : const Color(0xFFD4DFDC)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Text('${_day.year}. ${_two(_day.month)}. ${_two(_day.day)}.', style: Theme.of(context).textTheme.titleLarge)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: takiYellowSoft, borderRadius: BorderRadius.circular(14)),
                  child: Text('${items.length} munka', style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [takiYellowSoft, takiMint],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: takiOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.event_available_outlined,
                        size: 38,
                        color: takiTealDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Erre a napra nincs elfogadott munka.', textAlign: TextAlign.center, style: TextStyle(color: takiTealDark, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            for (final work in items)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: Container(
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: takiTealDark, borderRadius: BorderRadius.circular(17)),
                    child: Text('${work['time']}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                  title: Text('${work['service'] ?? work['title']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${work['address']}\n${WorkSchedule.minutes(work)} perc • ${work['status']}'),
                  trailing: const Icon(Icons.chevron_right),
                  isThreeLine: true,
                  onTap: () async {
                    await Navigator.pushNamed(context, '/order/details', arguments: {...work, 'view_role': _role});
                    await _load();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
