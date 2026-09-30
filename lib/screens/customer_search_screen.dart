import "package:flutter/material.dart";

import "../services/local_marketplace_store.dart";
import "../services/sanctions_store.dart";
import "../utils/district_utils.dart";

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});
  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  String? _service;
  String? _address;
  DateTime? _date;
  TimeOfDay? _time;
  int? _district;
  final _noteController = TextEditingController();

  final _services = const [
    {"name": "Apartmantakarítás", "icon": Icons.apartment},
    {
      "name": "Mosodai szolgáltatás",
      "icon": Icons.local_laundry_service,
    },
    {"name": "Általános takarítás", "icon": Icons.cleaning_services},
    {"name": "Nagytakarítás", "icon": Icons.soap},
    {"name": "Vízszerelés", "icon": Icons.water_damage},
    {"name": "Gázszerelés", "icon": Icons.local_fire_department},
    {"name": "Karbantartás", "icon": Icons.build},
    {"name": "Klíma", "icon": Icons.ac_unit},
    {"name": "Bútorszerelés", "icon": Icons.chair_alt},
  ];

  Future<void> _pickAddress() async {
    final res = await Navigator.pushNamed(context, "/map_picker");
    if (res is Map) {
      final address = res["address"]?.toString();
      final district = res["district"];
      if (address != null && address.isNotEmpty) {
        setState(() {
          _address = address;
          _district = district is int ? district : null;
        });
      }
    } else if (res is String && res.isNotEmpty) {
      setState(() => _address = res);
    }
  }

  Future<int?> _askDistrictFallback() async => showDialog<int>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text("Melyik kerületben van a cím?"),
          children: List.generate(23, (index) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, index + 1),
            child: Text("Budapest ${romanFromDistrict(index + 1)}. kerület"),
          )),
        ),
      );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => _time = t);
  }

  Future<void> _search() async {
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
    if (!await LocalMarketplaceStore.canCustomerCreateOrder()) {
      if (!mounted) return;
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
    if (_service == null ||
        _address == null ||
        _date == null ||
        _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Töltsd ki a szolgáltatás, cím, dátum és idő mezőket."),
        ),
      );
      return;
    }
    if (_district == null) {
      final selectedDistrict = await _askDistrictFallback();
      if (selectedDistrict == null || !mounted) return;
      setState(() => _district = selectedDistrict);
    }
    final dateTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    if (!dateTime.isAfter(DateTime.now().add(const Duration(hours: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Olyan időpontot válassz, amely legalább 1 órával később van.",
          ),
        ),
      );
      return;
    }
    final requestId = await LocalMarketplaceStore.createRequest(
      service: _service!,
      district: romanFromDistrict(_district!),
      address: _address!,
      dateTime: dateTime,
      note: _noteController.text.trim(),
      laundryAndIroning:
          _service == "Mosodai szolgáltatás",
    );
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      "/offers",
      arguments: {
        "request_id": requestId,
        "service": _service,
        "district": romanFromDistrict(_district!),
        "address": _address,
        "date": _date,
        "time": _time,
        "laundry_and_ironing":
            _service == "Mosodai szolgáltatás",
      },
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
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
      appBar: AppBar(title: const Text("Szolgáltató keresése")),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: ListView(
        
          children: [
            DropdownButtonFormField<String>(
              value: _service,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Szolgáltatás",
                prefixIcon: Icon(Icons.cleaning_services_outlined),
              ),
              items: _services.map((o) {
                final name = o["name"] as String;
                return DropdownMenuItem(value: name, child: Text(name));
              }).toList(),
              onChanged: (value) => setState(() => _service = value),
            ),
            const SizedBox(height: 12),

            // CÍM (Google Maps külön képernyő)
            ListTile(
              onTap: _pickAddress,
              leading: const Icon(Icons.map),
              title: Text(_address ?? "Cím kiválasztása (Google Maps)"),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0x22000000)),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(dFmt(_date)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTime,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(tFmt(_time)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Megjegyzés (opcionális)",
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _search,
            child: const Text("Keresés"),
          ),
        ),
      ),
    );
  }
}
