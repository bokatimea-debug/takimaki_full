import 'package:flutter/material.dart';

import '../services/local_marketplace_store.dart';
import '../services/sanctions_store.dart';
import '../theme.dart';
import '../widgets/branded_background.dart';
import '../widgets/service_choice_grid.dart';
import '../widgets/taki_app_bar.dart';

/// Fast request flow. It deliberately does not collect the service price:
/// customer and provider settle that amount directly with each other.
class CustomerSosRequestScreen extends StatefulWidget {
  const CustomerSosRequestScreen({super.key});

  @override
  State<CustomerSosRequestScreen> createState() => _CustomerSosRequestScreenState();
}

class _CustomerSosRequestScreenState extends State<CustomerSosRequestScreen> {
  String? _service;
  int _hours = 2;
  bool _saving = false;
  final _address = TextEditingController();
  final _price = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _address.dispose();
    _price.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickService() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .86,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: ServiceChoiceGrid(
              selected: _service,
              compact: true,
              onSelected: (value) => Navigator.pop(context, value),
            ),
          ),
        ),
      ),
    );
    if (selected != null && mounted) setState(() => _service = selected);
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (_service == null || _address.text.trim().isEmpty ||
        (int.tryParse(_price.text.trim()) ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Válassz szolgáltatást, add meg a címet és a munkadíjat.'),
      ));
      return;
    }
    if (await SanctionsStore.isCustomerSuspended()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Felfüggesztett fiókkal nem adhatsz fel expressz rendelést.'),
      ));
      return;
    }
    setState(() => _saving = true);
    try {
      await LocalMarketplaceStore.createSosRequest(
        service: _service!,
        address: _address.text.trim(),
        note: _note.text.trim(),
        arrivalWithinHours: _hours,
        listedPrice: int.parse(_price.text.trim()),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Az expressz rendelés kiment az elérhető szolgáltatóknak.'),
      ));
    } on StateError catch (error) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Expressz rendelés')),
    body: BrandedBackground(
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            TakiPanel(
              color: const Color(0xFFFFE2D6),
              padding: const EdgeInsets.all(14),
              child: const Row(children: [
                Icon(Icons.bolt_rounded, color: takiOrange, size: 28),
                SizedBox(width: 10),
                Expanded(child: Text(
                  'Sürgős munkát kérsz. A kiírt díjat közvetlenül a szolgáltatónak fizeted.',
                  style: TextStyle(fontWeight: FontWeight.w700, height: 1.3),
                )),
              ]),
            ),
            const SizedBox(height: 14),
            const Text('Mikor érkezzen meg?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: takiTealDark)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1 órán belül')),
                ButtonSegment(value: 2, label: Text('2 órán belül')),
                ButtonSegment(value: 3, label: Text('3 órán belül')),
              ],
              selected: {_hours},
              onSelectionChanged: (value) => setState(() => _hours = value.first),
            ),
            const SizedBox(height: 16),
            const Text('Milyen segítség kell?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: takiTealDark)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickService,
              icon: const Icon(Icons.handyman_outlined),
              label: Text(_service ?? 'Szolgáltatás kiválasztása'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Pontos cím', prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Felajánlott munkadíj', suffixText: 'Ft', prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Rövid leírás (opcionális)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: takiOrange,
                foregroundColor: takiTealDark,
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _saving ? null : _submit,
              icon: const Icon(Icons.bolt_rounded),
              label: Text(_saving ? 'Küldés...' : 'Expressz rendelés kiküldése'),
            ),
          ],
        ),
      ),
    ),
  );
}
