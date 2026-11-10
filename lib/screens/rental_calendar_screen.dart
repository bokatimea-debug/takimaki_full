import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/rental_calendar.dart';
import '../theme.dart';
import '../widgets/taki_app_bar.dart';
import '../widgets/taki_screen_header.dart';
import 'customer_search_screen.dart';

class RentalCalendarScreen extends StatefulWidget {
  const RentalCalendarScreen({super.key});

  @override
  State<RentalCalendarScreen> createState() => _RentalCalendarScreenState();
}

class _RentalCalendarScreenState extends State<RentalCalendarScreen>
    with WidgetsBindingObserver {
  static const _storageKey = 'rental_calendar_feeds';
  List<_Feed> _feeds = [];
  Map<_Feed, List<RentalStay>> _stays = {};
  Set<_Feed> _failed = {};
  bool _busy = true;
  bool _editing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    try {
      final data = jsonDecode(prefs.getString(_storageKey) ?? '[]') as List;
      _feeds = data
          .map(
            (e) => _Feed(
              e[0] as String,
              RentalSource.values.byName(e[1] as String),
              e[2] as String,
            ),
          )
          .toList();
    } catch (_) {
      _feeds = [];
    }
    _busy = false;
    await _refresh();
    if (!mounted) return;
    _timer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          ModalRoute.of(context)?.isCurrent == true)
        _refresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ModalRoute.of(context)?.isCurrent == true)
      _refresh();
  }

  Future<void> _refresh() async {
    if (_busy || _editing || !mounted) return;
    setState(() => _busy = true);
    final stays = <_Feed, List<RentalStay>>{};
    final failed = <_Feed>{};
    await Future.wait(
      _feeds.map((feed) async {
        try {
          stays[feed] = await fetchRentalCalendar(feed.source, feed.link);
        } catch (_) {
          failed.add(feed);
        }
      }),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _stays = stays;
      _failed = failed;
    });
  }

  Future<void> _save(List<_Feed> feeds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      if (!await prefs.setString(
        _storageKey,
        jsonEncode(
          feeds.map((f) => [f.address, f.source.name, f.link]).toList(),
        ),
      )) {
        throw StateError('Calendar save failed');
      }
      if (!mounted) return;
      setState(() => _feeds = feeds);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A naptár mentése nem sikerült.')),
        );
    }
  }

  Future<void> _add() async {
    setState(() => _editing = true);
    final feed = await showDialog<_Feed>(
      context: context,
      builder: (_) => const _FeedDialog(),
    );
    if (!mounted) return;
    if (feed != null) {
      await _save([
        ..._feeds.where(
          (f) =>
              f.link != feed.link &&
              !(f.source == feed.source &&
                  f.address.toLowerCase() == feed.address.toLowerCase()),
        ),
        feed,
      ]);
    }
    if (!mounted) return;
    setState(() => _editing = false);
    await _refresh();
  }

  Future<void> _remove(_Feed feed) async {
    setState(() => _editing = true);
    await _save(_feeds.where((f) => f != feed).toList());
    if (!mounted) return;
    setState(() => _editing = false);
    await _refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final merged = <(String, DateTime), (_Feed, RentalStay)>{};
    for (final entry in _stays.entries) {
      for (final stay in entry.value) {
        if (stay.checkout.isBefore(today)) continue;
        final key = (entry.key.address.toLowerCase(), stay.checkout);
        if (!merged.containsKey(key) || stay.verified) {
          merged[key] = (entry.key, stay);
        }
      }
    }
    final items = merged.values.toList()
      ..sort((a, b) => a.$2.checkout.compareTo(b.$2.checkout));
    final locked = _busy || _editing;
    return Scaffold(
      appBar: TakiAppBar(title: const Text('Szállásnaptárak')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const TakiScreenHeader(
              title: 'Airbnb és Booking.com',
              subtitle: 'Takarítás előkészítése vendégváltáshoz',
              icon: Icons.event_available_outlined,
            ),
            const SizedBox(height: 12),
            const Text(
              'A naptár megnyitáskor és nyitva tartva 15 percenként frissül. '
              'A takarítás időpontját és a rendelést te hagyod jóvá.',
            ),
            if (kIsWeb)
              const Text('A naptárimport a telefonos alkalmazásban érhető el.')
            else ...[
              FilledButton(
                onPressed: locked ? null : _add,
                child: const Text('Naptárlink hozzáadása'),
              ),
              if (_feeds.isNotEmpty)
                OutlinedButton(
                  onPressed: locked ? null : _refresh,
                  child: const Text('Frissítés'),
                ),
            ],
            if (_busy) const LinearProgressIndicator(),
            for (final feed in _feeds)
              Card(
                color: takiCardMint,
                child: ListTile(
                  title: Text(feed.address),
                  subtitle: Text(
                    _failed.contains(feed)
                        ? '${feed.source.label} · Nem sikerült frissíteni'
                        : feed.source.label,
                  ),
                  trailing: IconButton(
                    tooltip: 'Naptár leválasztása',
                    onPressed: locked ? null : () => _remove(feed),
                    icon: const Icon(Icons.link_off),
                  ),
                ),
              ),
            if (!locked && _feeds.isNotEmpty && items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nincs megjeleníthető közelgő vendégváltás.'),
              ),
            for (final (feed, stay) in items)
              Card(
                color: stay.verified ? takiCardMint : takiCardYellow,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feed.address,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${stay.checkout.year}. ${stay.checkout.month}. ${stay.checkout.day}.',
                      ),
                      Text(
                        stay.verified
                            ? '${feed.source.label} · Vendég távozása'
                            : 'Booking.com · Lezárt időszak. Ellenőrizd, hogy vendég távozik-e.',
                      ),
                      FilledButton(
                        onPressed: locked
                            ? null
                            : () async {
                                if (!stay.verified) {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        'Vendégváltás ellenőrzése',
                                      ),
                                      content: const Text(
                                        'Ellenőrizted a Booking.com felületén, hogy ezen a napon távozik vendég?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Mégse'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Igen'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed != true || !context.mounted)
                                    return;
                                }
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => CustomerSearchScreen(
                                      rentalDraft: RentalCleaningDraft(
                                        feed.address,
                                        stay.checkout,
                                      ),
                                    ),
                                  ),
                                );
                                if (mounted) _refresh();
                              },
                        child: const Text('Takarítás előkészítése'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Feed {
  const _Feed(this.address, this.source, this.link);
  final String address;
  final RentalSource source;
  final String link;
}

class _FeedDialog extends StatefulWidget {
  const _FeedDialog();
  @override
  State<_FeedDialog> createState() => _FeedDialogState();
}

class _FeedDialogState extends State<_FeedDialog> {
  final _form = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _link = TextEditingController();
  RentalSource _source = RentalSource.airbnb;

  @override
  void dispose() {
    _address.dispose();
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('Szállásnaptár csatlakoztatása'),
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<RentalSource>(
            value: _source,
            isExpanded: true,
            items: RentalSource.values
                .map(
                  (source) => DropdownMenuItem(
                    value: source,
                    child: Text(source.label),
                  ),
                )
                .toList(),
            onChanged: (source) => setState(() => _source = source!),
          ),
          TextFormField(
            controller: _address,
            maxLength: 180,
            decoration: const InputDecoration(labelText: 'Szállás címe'),
            validator: (value) =>
                value!.trim().isEmpty ? 'Add meg a címet.' : null,
          ),
          TextFormField(
            controller: _link,
            keyboardType: TextInputType.url,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(labelText: 'iCal exportlink'),
            validator: (value) {
              try {
                _source.validate(value ?? '');
                return null;
              } on FormatException catch (error) {
                return error.message;
              }
            },
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Mégse'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate())
            Navigator.pop(
              context,
              _Feed(_address.text.trim(), _source, _link.text.trim()),
            );
        },
        child: const Text('Csatlakoztatás'),
      ),
    ],
  );
}
