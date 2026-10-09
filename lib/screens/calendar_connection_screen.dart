import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/device_workflow.dart';
import '../theme.dart';
import '../widgets/taki_app_bar.dart';

class CalendarConnectionScreen extends StatefulWidget {
  const CalendarConnectionScreen({super.key});
  @override
  State<CalendarConnectionScreen> createState() =>
      _CalendarConnectionScreenState();
}

class _CalendarConnectionScreenState extends State<CalendarConnectionScreen> {
  String? _selected;
  String? _error;
  bool _busy = false;
  bool _registration = false;
  bool _autoRequested = false;
  List<Map<String, dynamic>> _calendars = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registration =
        ModalRoute.of(context)?.settings.arguments == 'registration';
    if (_registration && !_autoRequested) {
      _autoRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final prefs = await SharedPreferences.getInstance();
        if (mounted && !prefs.containsKey('phone_calendar_id')) {
          await _connect();
        }
      });
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted)
      setState(() {
        _selected = prefs.getString('phone_calendar_name');
        _error = prefs.getString('device_sync_error');
      });
  }

  Future<void> _connect() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!await DeviceWorkflow.permission('calendarPermission')) {
        if (mounted)
          setState(
            () => _error = 'Nincs engedély a telefon naptárához. A belső naptár továbbra is működik.',
          );
        return;
      }
      final calendars = await DeviceWorkflow.calendars();
      if (mounted)
        setState(() {
          _calendars = calendars;
          if (calendars.isEmpty) _error = 'Nincs írható naptár a telefonon.';
        });
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _choose(Map<String, dynamic> calendar) async {
    setState(() => _busy = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('phone_calendar_id', (calendar['id'] as num).toInt());
      await prefs.setString(
        'phone_calendar_name',
        '${calendar['name']} • ${calendar['account']}',
      );
      await DeviceWorkflow.syncExisting();
      if (mounted) setState(() => _calendars = []);
      await _load();
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('phone_calendar_id');
    await prefs.remove('phone_calendar_name');
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Saját naptár kapcsolata')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Az app saját naptárát mindig vezetjük. Ha szeretnéd, az elfogadott munkák a telefonodon elérhető Google-, Samsung- vagy más naptárba is automatikusan bekerülnek.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDDF4EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selected == null
                        ? 'Válaszd ki a Google-, Samsung- vagy más telefonos naptáradat.'
                        : 'Csatlakoztatva: $_selected',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          FilledButton(
            onPressed: _busy ? null : _connect,
            child: Text(
              _selected == null
                  ? 'Naptár kiválasztása'
                  : 'Másik naptár választása',
            ),
          ),
          for (final calendar in _calendars)
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.event_available_outlined),
                ),
                title: Text(calendar['name'].toString()),
                subtitle: Text(calendar['account'].toString()),
                trailing: const Icon(Icons.chevron_right),
                onTap: _busy ? null : () => _choose(calendar),
              ),
            ),
          if (_selected != null)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: takiMint,
                foregroundColor: takiTealDark,
                side: const BorderSide(color: takiTeal, width: 1.4),
              ),
              onPressed: _busy ? null : _disconnect,
              child: const Text('Automatikus hozzáadás kikapcsolása'),
            ),
          const Text(
            'Kikapcsoláskor a korábban hozzáadott események megmaradnak a telefon naptárában. Új munka vagy módosítás ezután csak az app saját naptárában jelenik meg.',
          ),
          if (_registration)
            FilledButton(
              onPressed: _busy
                  ? null
                  : () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/role_select',
                      (r) => false,
                    ),
              child: Text(
                _selected == null
                    ? 'Nem csatlakoztatok naptárt – tovább'
                    : 'Tovább',
              ),
            ),
        ],
      ),
    ),
  );
}
