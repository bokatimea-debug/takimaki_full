import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_backend.dart';

/// Property-level cleaning templates. A template belongs to an apartment
/// address and is copied into each work sheet, so later edits never change an
/// already completed job.
class CleaningChecklistTemplates {
  static const _key = 'cleaning_checklist_templates_v1';

  static const standard = <String, List<String>>{
    'Fürdőszoba': ['WC és öblítőgomb', 'Mosdó, tükör és csaptelep', 'Zuhanyzó/kád és hajszálak', 'Tiszta törölközők, WC-papír'],
    'Konyha': ['Mosogató és munkapult', 'Főzőlap, mikrohullámú sütő', 'Edények és poharak', 'Szemetes és bekészítések'],
    'Hálószoba': ['Használt textíliák összegyűjtve', 'Ágyazás és párnák', 'Felületek és kapcsolók', 'Padló és ágy alatti terület'],
    'Nappali és előszoba': ['Portalanítás felülről lefelé', 'Kanapé, párnák és textíliák', 'Elektronika külső felülete', 'Porszívózás és felmosás'],
  };

  static String idForAddress(String address) => address.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9áéíóöőúüű]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');

  static Future<Map<String, List<String>>> load(String address) async {
    final id = idForAddress(address);
    if (id.isEmpty) return Map<String, List<String>>.from(standard);
    final prefs = await SharedPreferences.getInstance();
    final all = _decode(prefs.getString(_key));
    Map<String, List<String>>? value = all[id];
    final backend = FirebaseBackend.instance;
    if (backend.isAvailable && backend.uid != null) {
      try {
        final remote = await backend.firestore.collection('cleaning_checklist_templates').doc('${backend.uid}_$id').get();
        final rooms = remote.data()?['rooms'];
        if (rooms is Map) value = _rooms(rooms);
      } catch (_) {}
    }
    return value == null || value.isEmpty ? Map<String, List<String>>.from(standard) : value;
  }

  static Future<void> save(String address, Map<String, List<String>> rooms) async {
    final id = idForAddress(address);
    if (id.isEmpty) throw StateError('Az ingatlan címére szükség van a checklist mentéséhez.');
    final prefs = await SharedPreferences.getInstance();
    final all = _decode(prefs.getString(_key));
    all[id] = rooms;
    await prefs.setString(_key, jsonEncode(all.map((key, value) => MapEntry(key, value))));
    final backend = FirebaseBackend.instance;
    if (!backend.isAvailable || backend.uid == null) return;
    await backend.firestore.collection('cleaning_checklist_templates').doc('${backend.uid}_$id').set({
      'owner_uid': backend.uid,
      'address': address,
      'rooms': rooms,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Map<String, Map<String, List<String>>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map;
      return decoded.map((key, value) => MapEntry(key.toString(), _rooms(value)));
    } catch (_) { return {}; }
  }

  static Map<String, List<String>> _rooms(dynamic value) {
    if (value is! Map) return {};
    return value.map((key, items) => MapEntry(key.toString(), (items as List? ?? const []).map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList()));
  }
}
