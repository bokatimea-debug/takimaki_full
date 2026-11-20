import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_backend.dart';

/// Registers this device for FCM. Delivery is triggered by the server-side
/// workflow when a shared order, chat or approval record changes.
class PushNotifications {
  static Future<void> initialize() async {
    final backend = FirebaseBackend.instance;
    if (!backend.isAvailable || backend.uid == null) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await messaging.getToken();
      if (token != null) await _saveToken(token);
      messaging.onTokenRefresh.listen(_saveToken);
    } catch (_) {
      // Notifications remain optional; the in-app notification list works.
    }
  }

  static Future<void> _saveToken(String token) async {
    final backend = FirebaseBackend.instance;
    if (!backend.isAvailable || backend.uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    await backend.firestore.collection('users').doc(backend.uid).set({
      'fcm_token': token,
      'fcm_updated_at': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}
