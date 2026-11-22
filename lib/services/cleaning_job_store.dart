import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_backend.dart';

/// Stores an apartment-cleaning work sheet separately from the marketplace
/// order. The local copy keeps an in-progress checklist usable offline; the
/// Firestore copy is the shared record once Firebase is available.
class CleaningJobStore {
  static String _key(String orderId) => 'cleaning_job_$orderId';

  static Future<Map<String, dynamic>> load(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(orderId));
    Map<String, dynamic> local = {};
    try {
      if (raw != null) local = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      local = {};
    }
    final backend = FirebaseBackend.instance;
    if (!backend.isAvailable) return local;
    try {
      final snapshot = await backend.firestore.collection('cleaning_jobs').doc(orderId).get();
      if (!snapshot.exists || snapshot.data() == null) return local;
      final remote = Map<String, dynamic>.from(snapshot.data()!);
      // Remote edits are shared; local fields fill only an offline draft that
      // does not yet exist in Firestore.
      return {...local, ...remote};
    } catch (_) { return local; }
  }

  static Future<void> save(String orderId, Map<String, dynamic> value) async {
    final now = DateTime.now().toIso8601String();
    final record = {...value, 'order_id': orderId, 'updated_at': now};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(orderId), jsonEncode(record));

    final backend = FirebaseBackend.instance;
    if (!backend.isAvailable || backend.uid == null) return;
    try {
      await backend.firestore
          .collection('cleaning_jobs')
          .doc(orderId)
          .set({
            ...record,
            'last_editor_uid': backend.uid,
            'created_by_uid': value['created_by_uid'] ?? backend.uid,
            'updated_at_server': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (_) {
      // The offline copy remains available and is retried on the next save.
    }
  }
}
