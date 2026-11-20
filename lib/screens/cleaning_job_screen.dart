import 'package:flutter/material.dart';

import '../services/cleaning_job_store.dart';
import '../services/remote_media_store.dart';
import '../theme.dart';
import '../widgets/branded_background.dart';
import '../widgets/taki_app_bar.dart';

class CleaningJobScreen extends StatefulWidget {
  const CleaningJobScreen({super.key});

  @override
  State<CleaningJobScreen> createState() => _CleaningJobScreenState();
}

class _CleaningJobScreenState extends State<CleaningJobScreen> {
  static const _standard = <String, List<String>>{
    'Fürdőszoba': ['WC és öblítőgomb', 'Mosdó, tükör és csaptelep', 'Zuhanyzó/kád és hajszálak', 'Tiszta törölközők, WC-papír'],
    'Konyha': ['Mosogató és munkapult', 'Főzőlap, mikrohullámú sütő', 'Edények és poharak', 'Szemetes és bekészítések'],
    'Hálószoba': ['Használt textíliák összegyűjtve', 'Ágyazás és párnák', 'Felületek és kapcsolók', 'Padló és ágy alatti terület'],
    'Nappali és előszoba': ['Portalanítás felülről lefelé', 'Kanapé, párnák és textíliák', 'Elektronika külső felülete', 'Porszívózás és felmosás'],
  };

  late String _orderId;
  bool _isOwner = false;
  String _cleaningType = 'Általános vendégváltási takarítás';
  bool _bringsSupplies = true;
  bool _loaded = false;
  bool _ownerApproved = false;
  String _ownerNote = '';
  Set<String> _checked = <String>{};
  Map<String, List<String>> _evidence = <String, List<String>>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    final order = args is Map ? Map<String, dynamic>.from(args) : <String, dynamic>{};
    _orderId = (order['request_id'] ?? order['id'] ?? 'draft').toString();
    _isOwner = order['view_role'] != 'provider';
    _load();
  }

  Future<void> _load() async {
    final data = await CleaningJobStore.load(_orderId);
    if (!mounted) return;
    setState(() {
      _cleaningType = data['type']?.toString() ?? _cleaningType;
      _bringsSupplies = data['brings_supplies'] as bool? ?? true;
      _ownerApproved = data['owner_approved'] as bool? ?? false;
      _ownerNote = data['owner_note']?.toString() ?? '';
      _checked = (data['checked'] as List? ?? const []).map((e) => e.toString()).toSet();
      final rawEvidence = data['evidence'];
      if (rawEvidence is Map) {
        _evidence = rawEvidence.map((key, value) => MapEntry(
              key.toString(),
              (value as List? ?? const []).map((entry) => entry.toString()).toList(),
            ));
      }
    });
  }

  Future<void> _save() => CleaningJobStore.save(_orderId, {
        'type': _cleaningType,
        'brings_supplies': _bringsSupplies,
        'checked': _checked.toList(),
        'owner_approved': _ownerApproved,
        'owner_note': _ownerNote,
        'evidence': _evidence,
      });

  int get _total => _standard.values.fold(0, (sum, items) => sum + items.length);
  int get _done => _checked.length;

  Future<void> _complete() async {
    final missingPhoto = _checked.where((id) => (_evidence[id] ?? const []).isEmpty).length;
    if (_done != _total || missingPhoto > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_done != _total
            ? 'Még ${_total - _done} checklistpont hiányzik.'
            : 'Még $missingPhoto kötelező ellenőrzőfotó hiányzik.')),
      );
      return;
    }
    await _save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A munkalap készen áll tulajdonosi ellenőrzésre.')),
    );
  }

  Future<void> _addEvidence(String id) async {
    try {
      final url = await RemoteMediaStore.pickAndUpload(
        folder: 'cleaning_evidence/$_orderId/${id.hashCode}',
      );
      if (url == null || !mounted) return;
      setState(() => _evidence = {
            ..._evidence,
            id: [...(_evidence[id] ?? const []), url],
          });
      await _save();
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A fotó feltöltése nem sikerült. Próbáld újra internetkapcsolattal.')));
      }
    }
  }

  Future<void> _ownerDecision(bool approved) async {
    final note = TextEditingController(text: _ownerNote);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approved ? 'Munka jóváhagyása' : 'Javítás kérése'),
        content: TextField(
          controller: note,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: approved ? 'Megjegyzés (opcionális)' : 'Mit kell javítani?',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Mégse')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(approved ? 'Jóváhagyás' : 'Javítás kérése')),
        ],
      ),
    );
    if (result == true) {
      setState(() { _ownerApproved = approved; _ownerNote = note.text.trim(); });
      await _save();
    }
    note.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: TakiAppBar(title: const Text('Apartmantakarítás')),
        body: BrandedBackground(
          child: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              children: [
                TakiPanel(
                  color: takiMint,
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [Icon(Icons.cleaning_services_rounded, color: takiTealDark), SizedBox(width: 8), Text('Munkalap és minőségellenőrzés', style: TextStyle(fontWeight: FontWeight.w800, color: takiNavy, fontSize: 17))]),
                    const SizedBox(height: 8),
                    Text('$_done / $_total pont elkészült', style: const TextStyle(color: takiMutedText)),
                    const SizedBox(height: 7),
                    LinearProgressIndicator(value: _total == 0 ? 0 : _done / _total, minHeight: 7, borderRadius: BorderRadius.circular(8)),
                  ]),
                ),
                const SizedBox(height: 10),
                TakiPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(children: [
                    DropdownButtonFormField<String>(
                      value: _cleaningType,
                      decoration: const InputDecoration(labelText: 'Takarítás típusa', border: InputBorder.none),
                      items: const ['Általános vendégváltási takarítás', 'Nagytakarítás'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) { if (v != null) setState(() => _cleaningType = v); _save(); },
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('A takarító hozza a szereket és eszközöket'),
                      value: _bringsSupplies,
                      onChanged: (v) { setState(() => _bringsSupplies = v); _save(); },
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                for (final room in _standard.entries) ...[
                  _RoomChecklist(
                    room: room.key,
                    items: room.value,
                    checked: _checked,
                    evidence: _evidence,
                    evidenceRequired: true,
                    onChanged: (id, value) async {
                      setState(() => value ? _checked.add(id) : _checked.remove(id));
                      await _save();
                    },
                    onAddEvidence: _addEvidence,
                  ),
                  const SizedBox(height: 10),
                ],
                TakiPanel(
                  color: _ownerApproved ? const Color(0xFFE6F6E8) : takiYellowSoft,
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Icon(_ownerApproved ? Icons.verified_rounded : Icons.pending_actions_rounded, color: _ownerApproved ? Colors.green.shade700 : takiOrange), const SizedBox(width: 8), Text(_ownerApproved ? 'Tulajdonos jóváhagyta' : 'Tulajdonosi ellenőrzésre vár', style: const TextStyle(fontWeight: FontWeight.w800, color: takiNavy))]),
                    if (_ownerNote.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(_ownerNote)),
                  ]),
                ),
                if (_isOwner) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () => _ownerDecision(false), icon: const Icon(Icons.reply_rounded), label: const Text('Javítás kérése'))),
                    const SizedBox(width: 8),
                    Expanded(child: FilledButton.icon(onPressed: _done == _total ? () => _ownerDecision(true) : null, icon: const Icon(Icons.verified_rounded), label: const Text('Jóváhagyás'))),
                  ]),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(onPressed: _complete, icon: const Icon(Icons.check_circle_outline), label: const Text('Checklist lezárása')),
              ],
            ),
          ),
        ),
      );
}

class _RoomChecklist extends StatelessWidget {
  const _RoomChecklist({required this.room, required this.items, required this.checked, required this.evidence, required this.evidenceRequired, required this.onChanged, required this.onAddEvidence});
  final String room;
  final List<String> items;
  final Set<String> checked;
  final Map<String, List<String>> evidence;
  final bool evidenceRequired;
  final Future<void> Function(String, bool) onChanged;
  final Future<void> Function(String) onAddEvidence;

  @override
  Widget build(BuildContext context) => TakiPanel(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(6, 4, 6, 3), child: Text(room, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: takiNavy))),
          for (final item in items) Builder(builder: (context) {
            final id = '$room:$item';
            final hasPhoto = (evidence[id] ?? const []).isNotEmpty;
            return Column(children: [
              CheckboxListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                controlAffinity: ListTileControlAffinity.leading,
                value: checked.contains(id),
                title: Text(item, style: const TextStyle(fontSize: 14)),
                subtitle: evidenceRequired ? Text(hasPhoto ? 'Ellenőrzőfotó feltöltve' : 'Ellenőrzőfotó kötelező', style: TextStyle(fontSize: 12, color: hasPhoto ? Colors.green.shade700 : takiMutedText)) : null,
                secondary: IconButton(
                  tooltip: 'Ellenőrzőfotó készítése',
                  icon: Icon(hasPhoto ? Icons.photo_camera_rounded : Icons.add_a_photo_outlined, color: hasPhoto ? Colors.green.shade700 : takiTeal),
                  onPressed: () => onAddEvidence(id),
                ),
                onChanged: (value) => onChanged(id, value ?? false),
              ),
              if (hasPhoto)
                Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 54, bottom: 6), child: Text('${evidence[id]!.length} feltöltött kép', style: const TextStyle(fontSize: 12, color: takiMutedText)))),
            ]);
          }),
        ]),
      );
}
