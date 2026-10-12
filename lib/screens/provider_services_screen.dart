import '../widgets/taki_screen_header.dart';
import '../widgets/service_choice_grid.dart';
import '../widgets/taki_app_bar.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../widgets/branded_background.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});
  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  List<Map<String, dynamic>> _items = [];
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('provider_services');
    if (raw == null || raw.isEmpty) {
      _items = [];
    } else {
      try {
        _items = (json.decode(raw) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {
        _items = [];
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('provider_services', json.encode(_items));
  }

  Future<void> _delete(int i) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const TakiScreenHeader(
          title: 'Szolgáltatás törlése',
          icon: Icons.info_outline_rounded,
        ),
        content: const Text('Biztosan eltávolítod ezt a szolgáltatást?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Törlés'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    setState(() => _items.removeAt(i));
    await _save();
  }

  Future<void> _open([Map<String, dynamic>? item]) async {
    final result = await Navigator.pushNamed(
      context,
      '/provider/add_service',
      arguments: item,
    );
    if (result == true) await _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Szolgáltatásaim')),
    body: SafeArea(
      top: false,
      child: _items.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: TakiEmptyState(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Még nincs szolgáltatásod',
                    text: 'Add meg, milyen munkákat vállalsz és milyen tájékoztató árakon.',
                    action: FilledButton.icon(
                      onPressed: () => _open(),
                      icon: const Icon(Icons.add),
                      label: const Text('Szolgáltatás hozzáadása'),
                    ),
                  ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                const TakiScreenHeader(
                  title: 'Saját szolgáltatások',
                  subtitle: 'Árak és elérhetőség kezelése',
                  icon: Icons.design_services_outlined,
                ),
                const SizedBox(height: 12),
                ..._items.asMap().entries.map(
                  (entry) => _serviceCard(entry.key, entry.value),
                ),
              ],
            ),
    ),
    bottomNavigationBar: _items.isEmpty
        ? null
        : SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: takiOrange,
                  foregroundColor: takiTealDark,
                ),
                onPressed: () => _open(),
                icon: const Icon(Icons.add),
                label: const Text('Új szolgáltatás'),
              ),
            ),
          ),
  );

  Widget _serviceCard(int index, Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? '';
    final priceRules = (item['price_rules'] as List?) ?? const [];
    final rules = priceRules.length;
    final dates = (item['dates'] as List?)?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TakiPanel(
        color: index.isEven ? takiCardMint : takiCardYellow,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  serviceImage(name),
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: takiTealDark,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'További műveletek',
                  padding: EdgeInsets.zero,
                  onSelected: (value) =>
                      value == 'edit' ? _open(item) : _delete(index),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Szerkesztés')),
                    PopupMenuItem(value: 'delete', child: Text('Törlés')),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rules == 0 ? 'Nincs ártétel' : '$rules ártétel',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: takiTealDark,
                        ),
                      ),
                      Text(
                        '${priceRules.take(2).map((rule) {
                          final map = rule as Map;
                          return map['label'] ?? '';
                        }).where((label) => label.toString().isNotEmpty).join(' • ')}${dates > 0 ? ' • $dates egyedi nap' : ' • Általános elérhetőség'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: takiTealDark,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Módosítás',
                  onPressed: () => _open(item),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
