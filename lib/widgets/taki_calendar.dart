import 'package:flutter/material.dart';

import '../theme.dart';
import 'taki_screen_header.dart';

/// Shared presentation for work calendars and single/multiple date selection.
/// Selection and availability rules remain with the caller.
class TakiMonthGrid extends StatelessWidget {
  const TakiMonthGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.onSelect,
    required this.onMonthChanged,
    this.enabled,
    this.workCount,
    this.previousEnabled = true,
    this.nextEnabled = true,
    this.dayKeyPrefix = 'month-day',
  });
  final DateTime month;
  final bool Function(DateTime) selected;
  final bool Function(DateTime)? enabled;
  final int Function(DateTime)? workCount;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<DateTime> onMonthChanged;
  final bool previousEnabled, nextEnabled;
  final String dayKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Előző hónap',
              onPressed: previousEnabled
                  ? () => onMonthChanged(DateTime(month.year, month.month - 1))
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                '${month.year}. ${const ['január', 'február', 'március', 'április', 'május', 'június', 'július', 'augusztus', 'szeptember', 'október', 'november', 'december'][month.month - 1]}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: takiNavy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Következő hónap',
              onPressed: nextEnabled
                  ? () => onMonthChanged(DateTime(month.year, month.month + 1))
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        Row(
          children: [
            for (final name in const ['H', 'K', 'Sze', 'Cs', 'P', 'Szo', 'V'])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: takiMutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ((leading + days + 6) ~/ 7) * 7,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent:
                (MediaQuery.textScalerOf(context).scale(16) * 1.5 + 16)
                    .clamp(48.0, 96.0)
                    .toDouble(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            final number = index - leading + 1;
            if (number < 1 || number > days) return const SizedBox.shrink();
            final date = DateTime(month.year, month.month, number);
            final isSelected = selected(date),
                available = enabled?.call(date) ?? true;
            final count = workCount?.call(date) ?? 0;
            return Material(
              color: isSelected
                  ? takiTeal
                  : !available
                  ? const Color(0xFFE8ECEB)
                  : date.weekday >= DateTime.saturday
                  ? takiCardYellow
                  : takiCardMint,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                key: ValueKey('$dayKeyPrefix-$number'),
                borderRadius: BorderRadius.circular(14),
                onTap: available ? () => onSelect(date) : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$number',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : available
                            ? takiNavy
                            : takiMutedText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (workCount != null) ...[
                      const SizedBox(height: 3),
                      Container(
                        width: count > 0 ? 20 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: count > 0 ? takiOrange : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

Future<DateTime?> showTakiDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final first = DateUtils.dateOnly(firstDate),
      last = DateUtils.dateOnly(lastDate);
  var date = DateUtils.dateOnly(initialDate);
  if (date.isBefore(first)) date = first;
  if (date.isAfter(last)) date = last;
  var month = DateTime(date.year, date.month);
  var manual = false;
  final formKey = GlobalKey<FormState>();
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, change) => AlertDialog(
        scrollable: true,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: TakiScreenHeader(
                      title: 'Dátum kiválasztása',
                      icon: Icons.calendar_month_outlined,
                    ),
                  ),
                  IconButton(
                    tooltip: manual ? 'Naptár megnyitása' : 'Dátum beírása',
                    onPressed: () => change(() => manual = !manual),
                    icon: Icon(
                      manual
                          ? Icons.calendar_month_outlined
                          : Icons.edit_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (manual)
                Form(
                  key: formKey,
                  child: InputDatePickerFormField(
                    initialDate: date,
                    firstDate: first,
                    lastDate: last,
                    onDateSaved: (d) => date = d,
                    onDateSubmitted: (d) => change(() => date = d),
                  ),
                )
              else
                TakiMonthGrid(
                  month: month,
                  selected: (d) => DateUtils.isSameDay(d, date),
                  enabled: (d) => !d.isBefore(first) && !d.isAfter(last),
                  previousEnabled: DateTime(
                    month.year,
                    month.month,
                  ).isAfter(DateTime(first.year, first.month)),
                  nextEnabled: DateTime(
                    month.year,
                    month.month,
                  ).isBefore(DateTime(last.year, last.month)),
                  onMonthChanged: (d) => change(() => month = d),
                  onSelect: (d) => change(() => date = d),
                  dayKeyPrefix: 'date-picker-day',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () {
              if (manual) {
                if (!formKey.currentState!.validate()) return;
                formKey.currentState!.save();
              }
              Navigator.pop(ctx, date);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
}

Future<TimeOfDay?> showTakiTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String? helpText,
}) => showTimePicker(
  context: context,
  initialTime: initialTime,
  helpText: helpText,
  builder: (ctx, child) => Theme(
    data: Theme.of(ctx).copyWith(
      timePickerTheme: TimePickerThemeData(
        backgroundColor: takiCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        hourMinuteColor: takiCardMint,
        hourMinuteTextColor: takiNavy,
        dialBackgroundColor: takiCardMint,
        dialHandColor: takiTeal,
        dayPeriodColor: takiCardYellow,
        dayPeriodTextColor: takiNavy,
        confirmButtonStyle: FilledButton.styleFrom(
          backgroundColor: takiOrange,
          foregroundColor: takiNavy,
        ),
      ),
    ),
    child: child!,
  ),
);
