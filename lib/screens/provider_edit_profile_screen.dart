import '../widgets/taki_app_bar.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../utils/profile_photo_loader.dart';
import '../widgets/city_picker.dart';
import '../widgets/profile_editor_components.dart';

class ProviderEditProfileScreen extends StatefulWidget {
  const ProviderEditProfileScreen({super.key});

  @override
  State<ProviderEditProfileScreen> createState() =>
      _ProviderEditProfileScreenState();
}

class _ProviderEditProfileScreenState extends State<ProviderEditProfileScreen> {
  final _bio = TextEditingController();
  String _firstName = '';
  String _city = 'Budapest';
  String? _photoPath;
  ImageProvider? _photoImage;
  TimeOfDay? _wdFrom, _wdTo, _weFrom, _weTo, _sunFrom, _sunTo;
  bool _holidays = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photo = await ProfilePhotoLoader.loadAny(role: 'provider');
      if (!mounted) return;
      setState(() {
        _firstName =
            prefs.getString('provider_first_name') ??
            prefs.getString('customer_first_name') ??
            prefs.getString('registration_first_name') ??
            '';
        _bio.text = prefs.getString('provider_bio') ?? '';
        _city =
            prefs.getString('provider_city') ??
            prefs.getString('profile_city') ??
            'Budapest';
        _photoImage = photo;
        _wdFrom = _parse(prefs.getString('provider_wd_from'));
        _wdTo = _parse(prefs.getString('provider_wd_to'));
        _weFrom = _parse(
          prefs.getString('provider_sat_from') ??
              (prefs.containsKey('provider_sat_configured')
                  ? null
                  : prefs.getString('provider_we_from')),
        );
        _weTo = _parse(
          prefs.getString('provider_sat_to') ??
              (prefs.containsKey('provider_sat_configured')
                  ? null
                  : prefs.getString('provider_we_to')),
        );
        _sunFrom = _parse(
          prefs.getString('provider_sun_from') ??
              (prefs.containsKey('provider_sun_configured')
                  ? null
                  : prefs.getString('provider_we_from')),
        );
        _sunTo = _parse(
          prefs.getString('provider_sun_to') ??
              (prefs.containsKey('provider_sun_configured')
                  ? null
                  : prefs.getString('provider_we_to')),
        );
        _holidays = prefs.getBool('provider_holidays') ?? false;
        _loading = false;
      });
    } catch (_) {
      _showError('Nem sikerült betölteni a profilt. Próbáld újra.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  TimeOfDay? _parse(String? hhmm) {
    final pieces = hhmm?.split(':');
    if (pieces == null || pieces.length != 2) return null;
    final hour = int.tryParse(pieces[0]);
    final minute = int.tryParse(pieces[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _fmt(TimeOfDay? time) => time == null
      ? '--:--'
      : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickRange({required bool weekend, bool sunday = false}) async {
    final fromInit = sunday
        ? (_sunFrom ?? const TimeOfDay(hour: 9, minute: 0))
        : weekend
        ? (_weFrom ?? const TimeOfDay(hour: 9, minute: 0))
        : (_wdFrom ?? const TimeOfDay(hour: 9, minute: 0));
    final toInit = sunday
        ? (_sunTo ?? const TimeOfDay(hour: 17, minute: 0))
        : weekend
        ? (_weTo ?? const TimeOfDay(hour: 17, minute: 0))
        : (_wdTo ?? const TimeOfDay(hour: 17, minute: 0));
    final from = await showTimePicker(
      context: context,
      initialTime: fromInit,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (from == null || !mounted) return;
    final to = await showTimePicker(
      context: context,
      initialTime: toInit,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (to == null || !mounted) return;
    if (to.hour * 60 + to.minute <= from.hour * 60 + from.minute) {
      _showError('A befejezés a kezdés után legyen.');
      return;
    }
    setState(() {
      if (sunday) {
        _sunFrom = from;
        _sunTo = to;
      } else if (weekend) {
        _weFrom = from;
        _weTo = to;
      } else {
        _wdFrom = from;
        _wdTo = to;
      }
    });
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 88,
      );
      if (image == null || !mounted) return;
      setState(() {
        _photoPath = image.path;
        _photoImage = FileImage(File(image.path));
      });
    } catch (_) {
      _showError('Nem sikerült megnyitni a képet. Próbáld újra.');
    }
  }

  Future<void> _pickCity() async {
    FocusScope.of(context).unfocus();
    final city = await showCityPicker(context, selectedCity: _city);
    if (city != null && mounted) setState(() => _city = city);
  }

  Future<void> _save() async {
    if (_saving || _loading) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_photoPath != null) {
        await ProfilePhotoLoader.saveFromPath(_photoPath!, role: 'provider');
      }
      await _write(prefs, 'provider_bio', _bio.text.trim());
      await _write(prefs, 'provider_city', _city);
      if (_wdFrom == null) {
        await prefs.remove('provider_wd_from');
        await prefs.remove('provider_wd_to');
      } else {
        await _write(prefs, 'provider_wd_from', _fmt(_wdFrom));
        await _write(prefs, 'provider_wd_to', _fmt(_wdTo));
      }
      for (final entry in {
        'sat': [_weFrom, _weTo],
        'sun': [_sunFrom, _sunTo],
      }.entries) {
        for (var i = 0; i < 2; i++) {
          final key = 'provider_${entry.key}_${i == 0 ? 'from' : 'to'}';
          final value = entry.value[i];
          if (value == null) {
            await prefs.remove(key);
          } else {
            await _write(prefs, key, _fmt(value));
          }
        }
        await prefs.setBool('provider_${entry.key}_configured', true);
      }
      await prefs.setBool('provider_holidays', _holidays);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      _showError('Nem sikerült menteni a módosításokat. Próbáld újra.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _write(SharedPreferences prefs, String key, String value) async {
    if (!await prefs.setString(key, value)) {
      throw StateError('Profile save failed');
    }
  }

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TakiAppBar(title: const Text('Profil szerkesztése')),
    body: ProfileEditorBody(
      children: [
        ProfileEditorCard(
          firstName: _firstName,
          photo: _photoImage,
          bio: _bio,
          city: _city,
          enabled: !_loading && !_saving,
          onPickPhoto: _pickPhoto,
          onPickCity: _pickCity,
        ),
        const SizedBox(height: 12),
        const Text(
          'Általános elérhetőség',
          style: TextStyle(
            fontSize: 17,
            color: takiNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        _TimeCard(
          title: 'Hétköznap',
          subtitle: _wdFrom == null ? 'Nem dolgozom' : '${_fmt(_wdFrom)} – ${_fmt(_wdTo)}',
          icon: Icons.work_outline_rounded,
          color: takiMint,
          onTap: _loading || _saving ? null : () => _pickRange(weekend: false),
          enabled: _wdFrom != null,
          onChanged: _loading || _saving ? null : (value) => setState(() {
            if (value) {
              _wdFrom = const TimeOfDay(hour: 9, minute: 0);
              _wdTo = const TimeOfDay(hour: 17, minute: 0);
            } else {
              _wdFrom = null;
              _wdTo = null;
            }
          }),
        ),
        const SizedBox(height: 8),
        _TimeCard(
          title: 'Szombat',
          subtitle: '${_fmt(_weFrom)} – ${_fmt(_weTo)}',
          icon: Icons.wb_sunny_outlined,
          color: takiYellowSoft,
          onTap: _loading || _saving ? null : () => _pickRange(weekend: true),
          enabled: _weFrom != null,
          onChanged: _loading || _saving ? null : (value) => setState(() {
            if (value) {
              _weFrom = const TimeOfDay(hour: 9, minute: 0);
              _weTo = const TimeOfDay(hour: 14, minute: 0);
            } else {
              _weFrom = null;
              _weTo = null;
            }
          }),
        ),
        const SizedBox(height: 8),
        _TimeCard(
          title: 'Vasárnap',
          subtitle: _sunFrom == null
              ? 'Nem dolgozom / időpont megadása'
              : '${_fmt(_sunFrom)} – ${_fmt(_sunTo)}',
          icon: Icons.wb_sunny_outlined,
          color: takiMint,
          onTap: _loading || _saving
              ? null
              : () => _pickRange(weekend: true, sunday: true),
          enabled: _sunFrom != null,
          onChanged: _loading || _saving ? null : (value) => setState(() {
            if (value) {
              _sunFrom = const TimeOfDay(hour: 9, minute: 0);
              _sunTo = const TimeOfDay(hour: 14, minute: 0);
            } else {
              _sunFrom = null;
              _sunTo = null;
            }
          }),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Ünnepnapon is vállalok munkát'),
          subtitle: Text(_holidays ? 'Igen' : 'Nem'),
          value: _holidays,
          onChanged: _loading || _saving
              ? null
              : (value) => setState(() => _holidays = value),
        ),
        ProfileEditorActions(enabled: !_loading, busy: _saving, onSave: _save),
      ],
    ),
  );
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: takiNavy, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: takiNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: takiMutedText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
