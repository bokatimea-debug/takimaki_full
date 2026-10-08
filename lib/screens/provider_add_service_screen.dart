import '../widgets/taki_app_bar.dart';

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "dart:convert";

import "../data/service_pricing_catalog.dart";
import "../theme.dart";
import "../widgets/branded_background.dart";
import "../widgets/service_choice_grid.dart";

class ProviderAddServiceScreen extends StatefulWidget {
  const ProviderAddServiceScreen({super.key});
  @override
  State<ProviderAddServiceScreen> createState() =>
      _ProviderAddServiceScreenState();
}

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  String? _service;
  final _pricingNoteCtrl = TextEditingController();
  final Set<DateTime> _dates = {};
  final Map<DateTime, TimeOfDay> _dateFrom = {};
  final Map<DateTime, TimeOfDay> _dateTo = {};
  final List<Map<String, dynamic>> _priceRules = [];
  final Set<String> _serviceOptions = {};
  bool _argumentsLoaded = false;
  bool _isEditing = false;
  String _city = 'Budapest';
  final Map<String, String> _generalHours = {};
  final Set<String> _changedHours = {};
  String? _serviceError;
  String? _priceError;
  String? _saveError;
  bool _saving = false;
  bool _holidays = false;
  final _serviceFieldKey = GlobalKey();
  final _priceFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  Future<void> _loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      for (final key in [
        'wd_from',
        'wd_to',
        'sat_from',
        'sat_to',
        'sun_from',
        'sun_to',
      ]) {
        final value =
            prefs.getString('provider_$key') ??
            (!prefs.containsKey(
                      'provider_${key.split('_').first}_configured',
                    ) &&
                    (key.startsWith('sat_') || key.startsWith('sun_'))
                ? prefs.getString('provider_we_${key.split('_').last}')
                : null);
        if (value != null) _generalHours[key] = value;
      }
      _holidays = prefs.getBool('provider_holidays') ?? false;
      _city =
          prefs.getString('provider_city') ??
          prefs.getString('profile_city') ??
          'Budapest';
    });
  }

  Future<void> _editGeneralHours(String period) async {
    final from = await showTimePicker(
      context: context,
      initialTime:
          _parseTime(_generalHours['${period}_from']) ??
          const TimeOfDay(hour: 9, minute: 0),
    );
    if (from == null || !mounted) return;
    final to = await showTimePicker(
      context: context,
      initialTime:
          _parseTime(_generalHours['${period}_to']) ??
          const TimeOfDay(hour: 17, minute: 0),
    );
    if (to == null || !mounted) return;
    if (to.hour * 60 + to.minute <= from.hour * 60 + from.minute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A befejezés a kezdés után legyen.')),
      );
      return;
    }
    String format(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    setState(() {
      _generalHours['${period}_from'] = format(from);
      _generalHours['${period}_to'] = format(to);
      _changedHours.add(period);
    });
  }

  Widget _generalHoursRow(String period, String label) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(
      color: period == 'sat' ? takiYellowSoft : takiMint,
      borderRadius: BorderRadius.circular(14),
    ),
    child: InkWell(
      key: ValueKey('general-hours-$period'),
      onTap: () => _editGeneralHours(period),
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: takiTealDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  _generalHours['${period}_from'] == null
                      ? 'Időpont megadása'
                      : '${_generalHours['${period}_from']} – ${_generalHours['${period}_to']}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: takiTealDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.edit_outlined, color: takiTealDark, size: 18),
              if (_generalHours['${period}_from'] != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Nem dolgozom ezen a napon',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() {
                    _generalHours.remove('${period}_from');
                    _generalHours.remove('${period}_to');
                    _changedHours.add(period);
                  }),
                )
              else
                const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentsLoaded) return;
    _argumentsLoaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _isEditing = true;
      _service = args["name"] as String?;
      _pricingNoteCtrl.text = args["pricing_note"]?.toString() ?? '';
      final options = args['service_options'];
      if (options is List) {
        _serviceOptions.addAll(options.map((value) => value.toString()));
      }
      final dts = (args["dates"] as List?)?.whereType<String>() ?? <String>[];
      _dates.addAll(dts.map(DateTime.tryParse).whereType<DateTime>());
      final hours = args["date_hours"];
      final rules = args["price_rules"];
      if (rules is List) {
        _priceRules.addAll(
          rules.whereType<Map>().map((rule) => Map<String, dynamic>.from(rule)),
        );
      }
      if (hours is Map) {
        for (final date in _dates) {
          final value = hours[_dateKey(date)];
          if (value is Map) {
            _dateFrom[date] =
                _parseTime(value["from"]?.toString()) ??
                const TimeOfDay(hour: 9, minute: 0);
            _dateTo[date] =
                _parseTime(value["to"]?.toString()) ??
                const TimeOfDay(hour: 18, minute: 0);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _pricingNoteCtrl.dispose();
    super.dispose();
  }

  String _fmtTh(int v) {
    final s = v.toString();
    final buf = <String>[];
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i - 1;
      buf.insert(0, s[idx]);
      if (i % 3 == 2 && idx != 0) buf.insert(0, " ");
    }
    return buf.join();
  }

  String _fmtDate(DateTime d) =>
      "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.";

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(":");
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _timeValue(TimeOfDay value) =>
      "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";

  Future<void> _pickDateHours(DateTime date) async {
    final from = await showTimePicker(
      context: context,
      initialTime: _dateFrom[date] ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: "Kezdés időpontja",
    );
    if (from == null || !mounted) return;
    final to = await showTimePicker(
      context: context,
      initialTime: _dateTo[date] ?? const TimeOfDay(hour: 18, minute: 0),
      helpText: "Befejezés időpontja",
    );
    if (to == null || !mounted) return;
    if (to.hour * 60 + to.minute <= from.hour * 60 + from.minute) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A befejezésnek később kell lennie a kezdésnél."),
        ),
      );
      return;
    }
    setState(() {
      _dateFrom[date] = from;
      _dateTo[date] = to;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = Set<DateTime>.from(_dates);
    final result = await showModalBottomSheet<Set<DateTime>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final selected = Set<DateTime>.from(initial);
        return StatefulBuilder(
          builder: (context, setModalState) => SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.72,
              child: Column(
                children: [
                  const Text(
                    "Egyedi napok",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text("Kiválasztva: ${selected.length}/10"),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.45,
                          ),
                      itemCount: 90,
                      itemBuilder: (context, index) {
                        final date = DateTime(
                          now.year,
                          now.month,
                          now.day + index,
                        );
                        final isSelected = selected.contains(date);
                        return FilterChip(
                          selected: isSelected,
                          label: Text(
                            "${date.month}.${date.day}.",
                            textAlign: TextAlign.center,
                          ),
                          onSelected: (value) {
                            if (value && selected.length >= 10) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Legfeljebb 10 egyedi nap választható.",
                                  ),
                                ),
                              );
                              return;
                            }
                            setModalState(() {
                              value
                                  ? selected.add(date)
                                  : selected.remove(date);
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, selected),
                        child: const Text("Kész"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result != null && mounted) {
      setState(() {
        _dates
          ..clear()
          ..addAll(result);
        _dateFrom.removeWhere((date, _) => !_dates.contains(date));
        _dateTo.removeWhere((date, _) => !_dates.contains(date));
        for (final date in _dates) {
          _dateFrom.putIfAbsent(
            date,
            () => const TimeOfDay(hour: 9, minute: 0),
          );
          _dateTo.putIfAbsent(date, () => const TimeOfDay(hour: 18, minute: 0));
        }
      });
    }
  }

  Future<void> _addPriceRule() async {
    if (_service == null) return;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _PriceRuleDialog(
        service: _service!,
        unavailableItems: _priceRules
            .map((rule) => rule['label']?.toString() ?? '')
            .toSet(),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _priceRules.add(result);
        _priceError = null;
      });
    }
  }

  void _revealField(GlobalKey fieldKey, {bool focusPrice = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final fieldContext = fieldKey.currentContext;
      if (fieldContext != null) {
        Scrollable.ensureVisible(
          fieldContext,
          alignment: .2,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    setState(() {
      _saveError = null;
      _serviceError = _service == null ? 'Válassz szolgáltatást.' : null;
      _priceError = _priceRules.isEmpty
          ? 'Adj hozzá legalább egy ártételt vagy egyedi árajánlatot.'
          : null;
    });
    if (_serviceError != null) {
      _revealField(_serviceFieldKey);
      return;
    }
    if (_priceError != null) {
      _revealField(_priceFieldKey);
      return;
    }

    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString("provider_services") ?? "[]";
      final list = (json.decode(raw) as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      final editingId = args is Map<String, dynamic> ? args["id"] : null;
      final duplicate = list.any(
        (item) => item["name"] == _service && item["id"] != editingId,
      );
      if (duplicate) {
        if (!mounted) return;
        setState(() {
          _serviceError = 'Ez a szolgáltatás már szerepel a listában.';
        });
        _revealField(_serviceFieldKey);
        return;
      }
      if (args is Map<String, dynamic>) {
        final idx = list.indexWhere((e) => e["id"] == args["id"]);
        final item = _buildItem(
          args["id"] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        );
        if (idx >= 0) {
          list[idx] = item;
        } else {
          list.add(item);
        }
      } else {
        list.add(_buildItem(DateTime.now().millisecondsSinceEpoch.toString()));
      }
      final saved = await prefs.setString(
        "provider_services",
        json.encode(list),
      );
      for (final period in _changedHours) {
        for (final edge in ['from', 'to']) {
          final value = _generalHours['${period}_$edge'];
          final ok = value == null
              ? await prefs.remove('provider_${period}_$edge')
              : await prefs.setString('provider_${period}_$edge', value);
          await prefs.setBool('provider_${period}_configured', true);
          if (!ok) throw StateError('availability-save-failed');
        }
      }
      if (!await prefs.setBool('provider_holidays', _holidays))
        throw StateError('availability-save-failed');
      if (!saved) throw StateError('service-save-failed');
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Szolgáltatás mentve")));
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saveError =
            'Nem sikerült menteni. Az adataid itt maradtak, próbáld újra.';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _chooseService() async {
    FocusScope.of(context).unfocus();
    final service = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .88,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'Válassz szolgáltatást',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ServiceChoiceGrid(
                    selected: _service,
                    onSelected: (name) => Navigator.pop(context, name),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (service != null && mounted && service != _service) {
      setState(() {
        _service = service;
        _serviceError = null;
        _priceError = null;
        _priceRules.clear();
        _serviceOptions.clear();
      });
    }
  }

  Map<String, dynamic> _buildItem(String id) {
    Map<String, dynamic>? firstPriced;
    for (final rule in _priceRules) {
      if (rule['price'] is int) {
        firstPriced = rule;
        break;
      }
    }
    final legacyPrice = firstPriced?['price'] as int?;
    return {
      "id": id,
      "name": _service,
      "price_raw": legacyPrice,
      "price_fmt": legacyPrice == null
          ? 'Egyedi árajánlat'
          : _fmtTh(legacyPrice),
      "unit": firstPriced?['unit'] ?? '',
      "dates": _dates
          .map((d) => DateTime(d.year, d.month, d.day).toIso8601String())
          .toList(),
      "date_hours": {
        for (final d in _dates)
          _dateKey(d): {
            "from": _timeValue(
              _dateFrom[d] ?? const TimeOfDay(hour: 9, minute: 0),
            ),
            "to": _timeValue(
              _dateTo[d] ?? const TimeOfDay(hour: 18, minute: 0),
            ),
          },
      },
      "price_rules": _priceRules,
      "service_options": _serviceOptions.toList(),
      "pricing_note": _pricingNoteCtrl.text.trim(),
    };
  }

  Widget _serviceOptionsPicker() {
    final options = serviceOptionLabels[_service] ?? const <String>[];
    if (options.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mit vállalsz?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: options.map((option) {
            final selected = _serviceOptions.contains(option);
            return FilterChip(
              key: ValueKey('service-option-detail-$option'),
              selected: selected,
              showCheckmark: true,
              backgroundColor: takiYellowSoft,
              selectedColor: takiTeal,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: selected ? takiTeal : const Color(0xFFE4C56F),
              ),
              labelStyle: TextStyle(
                color: selected ? Colors.white : takiTealDark,
                fontWeight: FontWeight.w800,
              ),
              label: Text(option),
              onSelected: (value) => setState(() {
                value
                    ? _serviceOptions.add(option)
                    : _serviceOptions.remove(option);
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _pricingBuilder() => KeyedSubtree(
    key: _priceFieldKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Árazás *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton.filledTonal(
              key: const ValueKey('add-price-rule'),
              tooltip: 'Ár hozzáadása',
              onPressed: _addPriceRule,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Csempéből válassz tételt. Egyedi árajánlatnál nem kell összeget megadni.',
          style: TextStyle(fontSize: 12, color: takiMutedText),
        ),
        if (_priceError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _priceError!,
              key: const ValueKey('service-price-error'),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ..._priceRules.asMap().entries.map((entry) {
          final rule = entry.value;
          final custom = rule['unit'] == 'Egyedi árajánlat';
          final price = rule['price'] as int?;
          return Card(
            color: entry.key.isEven ? takiMint : takiYellowSoft,
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.sell_outlined, color: takiTealDark),
              title: Text(
                rule['label']?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                custom
                    ? 'Egyedi árajánlat'
                    : '${_fmtTh(price ?? 0)} ${rule['unit'] ?? ''}',
              ),
              trailing: IconButton(
                tooltip: 'Ártétel törlése',
                onPressed: () =>
                    setState(() => _priceRules.removeAt(entry.key)),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ),
          );
        }),
        const SizedBox(height: 6),
        TextField(
          key: const ValueKey('pricing-note'),
          controller: _pricingNoteCtrl,
          maxLines: 1,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Megjegyzés az árakhoz (opcionális)',
            hintText: 'Például: A díj tartalmazza a tisztítószereket.',
            counterText: '',
            isDense: true,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final expandedText = MediaQuery.textScalerOf(context).scale(14) > 17;
    return Scaffold(
      appBar: TakiAppBar(
        title: Text(
          _isEditing ? 'Szolgáltatás szerkesztése' : 'Új szolgáltatás',
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SizedBox.expand(
              child: SingleChildScrollView(
                key: const ValueKey('service-form-scroll'),
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      key: _serviceFieldKey,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Szolgáltatás *',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Material(
                          color: takiMint,
                          borderRadius: BorderRadius.circular(18),
                          child: ListTile(
                            key: const ValueKey('service-selector'),
                            minTileHeight: 48,
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: _serviceError == null
                                    ? Colors.transparent
                                    : Theme.of(context).colorScheme.error,
                              ),
                            ),
                            leading: expandedText
                                ? null
                                : _service == null
                                ? const Icon(
                                    Icons.design_services_outlined,
                                    color: takiNavy,
                                  )
                                : Image.asset(
                                    serviceImage(_service!),
                                    width: 42,
                                    height: 42,
                                    fit: BoxFit.contain,
                                  ),
                            title: Text(
                              _service ?? 'Válassz szolgáltatást',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.expand_more,
                              color: takiNavy,
                            ),
                            onTap: _chooseService,
                          ),
                        ),
                        if (_serviceError != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                            child: Text(
                              _serviceError!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TakiPanel(
                      color: takiMint,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: takiNavy,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Működési terület',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: takiMutedText,
                                  ),
                                ),
                                Text(
                                  _city,
                                  key: const ValueKey('service-city'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (serviceNeedsPermitWarning(_service)) ...[
                      TakiPanel(
                        color: takiYellowSoft,
                        padding: const EdgeInsets.all(12),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: takiOrange,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Ezt a tevékenységet csak a szükséges képesítéssel és engedéllyel rendelkező szakember végezheti.',
                                style: TextStyle(fontSize: 12, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    _serviceOptionsPicker(),
                    if ((serviceOptionLabels[_service] ?? const <String>[])
                        .isNotEmpty)
                      const SizedBox(height: 8),
                    _pricingBuilder(),
                    const SizedBox(height: 6),
                    const Text(
                      'Elérhetőség',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _generalHoursRow('wd', 'Hétköznap'),
                    _generalHoursRow('sat', 'Szombat'),
                    _generalHoursRow('sun', 'Vasárnap'),
                    SwitchListTile.adaptive(
                      tileColor: takiYellowSoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.only(left: 12, right: 6),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        'Ünnepnap: ${_holidays ? 'igen' : 'nem'}',
                        style: const TextStyle(
                          color: takiTealDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      value: _holidays,
                      onChanged: (value) => setState(() => _holidays = value),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      key: const ValueKey('service-dates'),
                      onPressed: _pickDate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size.fromHeight(42),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon: const Icon(Icons.event_outlined, size: 21),
                      label: Text(
                        _dates.isEmpty
                            ? 'Egyedi napok kiválasztása'
                            : 'Kiválasztott napok: ${_dates.length}/10',
                      ),
                    ),
                    if (_dates.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...((_dates.toList()..sort((a, b) => a.compareTo(b))).map(
                        (date) => Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            title: Text(_fmtDate(date)),
                            subtitle: Text(
                              "${_timeValue(_dateFrom[date] ?? const TimeOfDay(hour: 9, minute: 0))}–${_timeValue(_dateTo[date] ?? const TimeOfDay(hour: 18, minute: 0))}",
                            ),
                            trailing: const Icon(Icons.schedule),
                            onTap: () => _pickDateHours(date),
                          ),
                        ),
                      )),
                    ],
                    const SizedBox(height: 6),
                    if (_saveError != null) ...[
                      Text(
                        _saveError!,
                        key: const ValueKey('service-save-error'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    FilledButton(
                      key: const ValueKey('service-save'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? 'Mentés…' : 'Mentés'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceRuleDialog extends StatefulWidget {
  final String service;
  final Set<String> unavailableItems;
  const _PriceRuleDialog({
    required this.service,
    required this.unavailableItems,
  });

  @override
  State<_PriceRuleDialog> createState() => _PriceRuleDialogState();
}

class _PriceRuleDialogState extends State<_PriceRuleDialog> {
  final _priceCtrl = TextEditingController();
  String? _item;
  String? _unit;
  String? _error;

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final custom = _unit == 'Egyedi árajánlat';
    final price = int.tryParse(_priceCtrl.text.replaceAll(" ", ""));
    if (_item == null ||
        _unit == null ||
        (!custom && (price == null || price <= 0))) {
      setState(
        () => _error = custom
            ? 'Válassz tételt és elszámolást.'
            : 'Válassz tételt, elszámolást és adj meg érvényes árat.',
      );
      return;
    }
    Navigator.pop(context, {
      'type': 'service_item',
      'label': _item,
      if (!custom) 'price': price,
      'unit': _unit,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: const Text('Ár hozzáadása'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Válassz tételt',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children:
                    (servicePriceItems[widget.service] ?? const <String>[])
                        .where(
                          (item) => !widget.unavailableItems.contains(item),
                        )
                        .map(
                          (item) => ChoiceChip(
                            key: ValueKey('price-item-$item'),
                            selected: _item == item,
                            backgroundColor: takiYellowSoft,
                            selectedColor: takiTeal,
                            side: BorderSide(
                              color: _item == item
                                  ? takiTeal
                                  : const Color(0xFFE4C56F),
                            ),
                            labelStyle: TextStyle(
                              color: _item == item
                                  ? Colors.white
                                  : takiTealDark,
                              fontWeight: FontWeight.w800,
                            ),
                            label: Text(item),
                            onSelected: (_) => setState(() {
                              _item = item;
                              _unit = null;
                              _priceCtrl.clear();
                            }),
                          ),
                        )
                        .toList(),
              ),
              if (_item != null) ...[
                const SizedBox(height: 14),
                const Text(
                  'Elszámolás',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: pricingUnitsFor(widget.service, _item!)
                      .map(
                        (unit) => ChoiceChip(
                          key: ValueKey('price-unit-$unit'),
                          selected: _unit == unit,
                          backgroundColor: takiMint,
                          selectedColor: takiTeal,
                          side: BorderSide(
                            color: _unit == unit
                                ? takiTeal
                                : const Color(0xFF9ACCC6),
                          ),
                          labelStyle: TextStyle(
                            color: _unit == unit ? Colors.white : takiTealDark,
                            fontWeight: FontWeight.w800,
                          ),
                          label: Text(unit),
                          onSelected: (_) => setState(() {
                            _unit = unit;
                            if (unit == 'Egyedi árajánlat') _priceCtrl.clear();
                          }),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (_unit != null && _unit != 'Egyedi árajánlat') ...[
                const SizedBox(height: 14),
                TextField(
                  key: const ValueKey('price-rule-amount'),
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: _unit == '%' ? 'Mérték (%)' : 'Összeg (Ft)',
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Mégse"),
        ),
        FilledButton(
          key: const ValueKey('price-rule-add'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(150, 46),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          ),
          onPressed: _submit,
          child: const Text("Hozzáadás"),
        ),
      ],
    );
  }
}
