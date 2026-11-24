import '../widgets/taki_app_bar.dart';

import "package:flutter/material.dart";

import "../data/service_pricing_catalog.dart";
import "../services/local_marketplace_store.dart";
import "../services/sanctions_store.dart";
import "../theme.dart";
import "../widgets/branded_background.dart";
import "../widgets/service_choice_grid.dart";

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key, this.startAsSos = false});
  final bool startAsSos;
  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  bool _saving = false;
  final Map<String, String> _errors = {};
  final _serviceKey = GlobalKey();
  final _addressKey = GlobalKey();
  final _areaKey = GlobalKey();
  final _dateKey = GlobalKey();
  final _timeKey = GlobalKey();
  void _reveal(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = key.currentContext;
      if (mounted && target != null)
        Scrollable.ensureVisible(
          target,
          alignment: .15,
          duration: const Duration(milliseconds: 200),
        );
    });
  }

  String? _service;
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _noteController = TextEditingController();
  final Set<String> _requestedOptions = {};
  bool _isSos = false;
  int _sosHours = 2;
  final _sosPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isSos = widget.startAsSos;
  }

  Future<void> _chooseService() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .88,
          child: Column(
            children: [
              const Text(
                'Válassz szolgáltatást',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ServiceChoiceGrid(
                    selected: _service,
                    compact: true,
                    onSelected: (name) => Navigator.pop(context, name),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted && selected != _service) {
      setState(() {
        _service = selected;
        _requestedOptions.clear();
        _errors.remove('service');
      });
    }
  }

  bool get _needsArea => const {
    'Apartmantakarítás',
    'Általános takarítás',
    'Nagytakarítás',
    'Felújítás utáni takarítás',
  }.contains(_service);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickStartTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) {
      setState(() {
        _startTime = t;
        if (_endTime == null || _minutesOf(_endTime!) <= _minutesOf(t)) {
          final suggested = _minutesOf(t) + 120;
          _endTime = suggested < 24 * 60
              ? TimeOfDay(hour: suggested ~/ 60, minute: suggested % 60)
              : null;
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final initial = _endTime ?? const TimeOfDay(hour: 11, minute: 0);
    final t = await showTimePicker(context: context, initialTime: initial);
    if (t != null) setState(() => _endTime = t);
  }

  int _minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> _search() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _submit();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A rendelés mentése nem sikerült. Próbáld újra.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submit() async {
    if (await SanctionsStore.isCustomerSuspended()) {
      final until = await SanctionsStore.customerSuspendedUntil();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "A fiók ${until?.toLocal().toString().split(' ').first ?? ''}-ig fel van függesztve.",
          ),
        ),
      );
      return;
    }
    final canCreate = await LocalMarketplaceStore.canCustomerCreateOrder();
    if (!mounted) return;
    if (!canCreate) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Előfizetés szükséges"),
          content: const Text(
            "A 3 hónapos ingyenes időszak lejárt. Új rendeléshez 3 000 Ft/hó megrendelői előfizetés szükséges.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/subscriptions");
              },
              child: const Text("Előfizetések"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Rendben"),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      _errors.clear();
      if (_service == null) _errors['service'] = 'Válassz szolgáltatást.';
      if (_addressController.text.trim().isEmpty)
        _errors['address'] = 'Add meg a címet.';
      if (_needsArea && (int.tryParse(_areaController.text.trim()) ?? 0) <= 0)
        _errors['area'] = 'Adj meg érvényes alapterületet.';
      if (!_isSos && _date == null) _errors['date'] = 'Válassz dátumot.';
      if (!_isSos && (_startTime == null || _endTime == null))
        _errors['time'] = 'Add meg a kezdést és a befejezést.';
      if (_isSos && (int.tryParse(_sosPriceController.text.trim()) ?? 0) <= 0) {
        _errors['sosPrice'] = 'Adj meg érvényes munkadíjat.';
      }
    });
    if (_errors.isNotEmpty) {
      _reveal(
        {
          'service': _serviceKey,
          'address': _addressKey,
          'area': _areaKey,
          'date': _dateKey,
          'time': _timeKey,
        }[_errors.keys.first]!,
      );
      return;
    }
    final dateTime = _isSos
        ? DateTime.now()
        : DateTime(_date!.year, _date!.month, _date!.day, _startTime!.hour, _startTime!.minute);
    if (!_isSos && !dateTime.isAfter(DateTime.now().add(const Duration(hours: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Olyan időpontot válassz, amely legalább 1 órával később van.",
          ),
        ),
      );
      return;
    }
    final durationMinutes = _isSos ? 120 : _minutesOf(_endTime!) - _minutesOf(_startTime!);
    if (durationMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "A befejezési időnek későbbinek kell lennie a kezdésnél.",
          ),
        ),
      );
      return;
    }
    final laundry = _service == "Mosodai szolgáltatás" ||
        _requestedOptions.contains('Mosodai szolgáltatás') ||
        _requestedOptions.contains('Helyszíni mosás');
    final requestId = _isSos
        ? await LocalMarketplaceStore.createSosRequest(
            service: _service!, address: _addressController.text.trim(), note: _noteController.text.trim(),
            arrivalWithinHours: _sosHours, listedPrice: int.parse(_sosPriceController.text.trim()),
            durationMinutes: durationMinutes, serviceOptions: _requestedOptions.toList(),
            areaSqm: _needsArea ? int.parse(_areaController.text.trim()) : null, laundryAndIroning: laundry,
          )
        : await LocalMarketplaceStore.createRequest(
            durationMinutes: durationMinutes, service: _service!, address: _addressController.text.trim(),
            dateTime: dateTime, note: _noteController.text.trim(), laundryAndIroning: laundry,
            serviceOptions: _requestedOptions.toList(), areaSqm: _needsArea ? int.parse(_areaController.text.trim()) : null,
          );
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      "/offers",
      arguments: {
        "request_id": requestId,
        "service": _service,
        "address": _addressController.text.trim(),
        "date": _date,
        "time": _startTime,
        "laundry_and_ironing":
            _service == "Mosodai szolgáltatás" ||
            _requestedOptions.contains('Mosodai szolgáltatás') ||
            _requestedOptions.contains('Helyszíni mosás'),
        "service_options": _requestedOptions.toList(),
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _areaController.dispose();
    _noteController.dispose();
    _sosPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dFmt(DateTime? d) => d == null
        ? "Válassz dátumot"
        : "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.";
    String tFmt(TimeOfDay? t) => t == null
        ? "Válassz időt"
        : "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: TakiAppBar(title: Text(_isSos ? 'Expressz rendelés' : 'Új megrendelés')),
      body: BrandedBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          children: [
            if (!widget.startAsSos)
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Expressz rendelés', style: TextStyle(fontWeight: FontWeight.w800, color: takiNavy)),
                subtitle: const Text('1–3 órás sürgős határidővel és elsőbbségi listázással.'),
                value: _isSos,
                onChanged: (value) => setState(() => _isSos = value),
              ),
            if (_isSos) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: takiYellowSoft, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Expressz rendelés feltételei', style: TextStyle(fontWeight: FontWeight.w800, color: takiNavy)),
                  const SizedBox(height: 4),
                  const Text('Elfogadás után a szolgáltató vállalja a megjelenést. Jelentett meg nem jelenéskor az SOS-jogosultság 3 hónapra felfüggeszthető.'),
                  const SizedBox(height: 8),
                  SegmentedButton<int>(
                    segments: const [ButtonSegment(value: 1, label: Text('1 óra')), ButtonSegment(value: 2, label: Text('2 óra')), ButtonSegment(value: 3, label: Text('3 óra'))],
                    selected: {_sosHours},
                    onSelectionChanged: (value) => setState(() => _sosHours = value.first),
                  ),
                ]),
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              'Szolgáltatás *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: takiNavy,
              ),
            ),
            const SizedBox(height: 8),
            Material(
              key: _serviceKey,
              color: takiMint,
              borderRadius: BorderRadius.circular(18),
              child: ListTile(
                key: const ValueKey('customer-service-selector'),
                minTileHeight: 56,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                leading: _service == null
                    ? const Icon(Icons.design_services_outlined, color: takiNavy)
                    : Image.asset(
                        serviceImage(_service!),
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                      ),
                title: Text(
                  _service ?? 'Válassz szolgáltatást',
                  style: const TextStyle(
                    color: takiNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing: const Icon(Icons.expand_more, color: takiNavy),
                onTap: _chooseService,
              ),
            ),
            if (_errors['service'] != null)
              Text(
                _errors['service']!,
                style: const TextStyle(color: Colors.red),
              ),
            if (serviceOptionLabels.containsKey(_service)) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: serviceOptionLabels[_service]!
                    .map(
                      (option) => FilterChip(
                        key: ValueKey('customer-option-$option'),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        selected: _requestedOptions.contains(option),
                        showCheckmark: true,
                        backgroundColor: takiYellowSoft,
                        selectedColor: takiTeal,
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: _requestedOptions.contains(option)
                              ? takiTeal
                              : const Color(0xFFE4C56F),
                        ),
                        labelStyle: TextStyle(
                          color: _requestedOptions.contains(option)
                              ? Colors.white
                              : takiTealDark,
                          fontWeight: FontWeight.w800,
                        ),
                        label: Text(option),
                        onSelected: (value) => setState(() {
                          value
                              ? _requestedOptions.add(option)
                              : _requestedOptions.remove(option);
                        }),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (_service == 'Apartmantakarítás') ...[
              const SizedBox(height: 8),
              const Text(
                'Kért tételek',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: servicePriceItems['Apartmantakarítás']!
                    .map(
                      (item) => FilterChip(
                        key: ValueKey('customer-item-$item'),
                        label: Text(item),
                        selected: _requestedOptions.contains(item),
                        backgroundColor: takiMint,
                        selectedColor: takiTeal,
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: _requestedOptions.contains(item)
                              ? takiTeal
                              : const Color(0xFF9ACCC6),
                        ),
                        labelStyle: TextStyle(
                          color: _requestedOptions.contains(item)
                              ? Colors.white
                              : takiTealDark,
                          fontWeight: FontWeight.w800,
                        ),
                        onSelected: (value) => setState(() {
                          value
                              ? _requestedOptions.add(item)
                              : _requestedOptions.remove(item);
                        }),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              key: _addressKey,
              controller: _addressController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                errorText: _errors['address'],
                labelText: "Cím kiválasztása",
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                hintText: "Budapest, utca és házszám",
                prefixIcon: Icon(Icons.location_on_outlined),
                suffixIcon: Icon(Icons.map_outlined),
              ),
            ),
            if (_needsArea) ...[
              const SizedBox(height: 8),
              TextField(
                key: _areaKey,
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  errorText: _errors['area'],
                  labelText: 'Alapterület (m²)',
                  hintText: 'Például 65',
                  isDense: true,
                  prefixIcon: Icon(Icons.square_foot_rounded),
                  suffixText: 'm²',
                ),
              ),
            ],
            if (_isSos) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _sosPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Felajánlott munkadíj',
                  suffixText: 'Ft',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  errorText: _errors['sosPrice'],
                ),
              ),
              const SizedBox(height: 4),
              const Text('A munkadíjat közvetlenül a megrendelő és a szolgáltató rendezi; a Takimaki nem kezeli a pénzt.', style: TextStyle(fontSize: 12, color: takiMutedText)),
            ] else ...[
            const SizedBox(height: 8),
            if (_errors['date'] != null)
              Text(_errors['date']!, style: const TextStyle(color: Colors.red)),
            OutlinedButton(
              key: _dateKey,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: _pickDate,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(dFmt(_date)),
              ),
            ),
            const SizedBox(height: 8),
            if (_errors['time'] != null)
              Text(_errors['time']!, style: const TextStyle(color: Colors.red)),
            Row(
              key: _timeKey,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _pickStartTime,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _startTime == null
                            ? "Kezdés"
                            : "Kezdés: ${tFmt(_startTime)}",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _pickEndTime,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _endTime == null
                            ? "Befejezés"
                            : "Befejezés: ${tFmt(_endTime)}",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: "Megjegyzés (opcionális)",
                hintText: "Írd le a feladat fontos részleteit…",
                alignLabelWithHint: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Icon(Icons.notes_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: takiTeal,
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onPressed: _saving ? null : _search,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _isSos ? "Expressz rendelés kiküldése" : "Ajánlatok kérése",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
