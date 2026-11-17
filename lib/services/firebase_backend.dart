import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// One controlled entry point for the Takimaki cloud backend.
///
/// Firebase is optional while an old local test installation is upgraded: the
/// screens stay usable, but all new builds initialise this service first and
/// can use [uid] as the immutable account identity for Firestore rules.
class FirebaseBackend {
  FirebaseBackend._();

  static final FirebaseBackend instance = FirebaseBackend._();

  bool _available = false;
  String? _startupError;

  bool get isAvailable => _available;
  String? get startupError => _startupError;
  String? get uid => FirebaseAuth.instance.currentUser?.uid;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      _available = FirebaseAuth.instance.currentUser != null;
      _startupError = null;
    } catch (error) {
      // Do not make an existing local test account inaccessible when a device
      // is offline or when it still lacks the Firebase config file.
      _available = false;
      _startupError = error.toString();
    }
  }

  /// Writes a profile under the authenticated account UID. A phone number is
  /// deliberately never used as a Firestore document ID.
  Future<void> saveProfile(Map<String, dynamic> profile) async {
    if (!_available || uid == null) return;
    try {
      await firestore.collection('users').doc(uid).set({
        ...profile,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> createRequest(Map<String, dynamic> request) async {
    if (!_available || uid == null) return;
    final id = request['id']?.toString();
    if (id == null || id.isEmpty) return;
    try {
      await firestore.collection('requests').doc(id).set({
        ...request,
        'customer_uid': uid,
        'updated_at': FieldValue.serverTimestamp(),
        'created_at_server': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> saveOffer(Map<String, dynamic> offer) async {
    if (!_available || uid == null) return;
    final id = offer['id']?.toString();
    if (id == null || id.isEmpty) return;
    try {
      await firestore.collection('offers').doc(id).set({
        ...offer,
        'provider_uid': uid,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> saveOrder(Map<String, dynamic> order) async {
    if (!_available || uid == null) return;
    final id = order['id']?.toString() ?? order['request_id']?.toString();
    if (id == null || id.isEmpty) return;
    try {
      await firestore.collection('orders').doc(id).set({
        ...order,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
