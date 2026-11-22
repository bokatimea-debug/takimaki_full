import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
  FirebaseFunctions get functions =>
      FirebaseFunctions.instanceFor(region: 'europe-west3');

  Future<Map<String, dynamic>?> submitAcademyExam(List<int> answers) async {
    if (!_available || uid == null) return null;
    try {
      final result = await functions
          .httpsCallable('submitAcademyExam')
          .call<Map<String, dynamic>>({'answers': answers});
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException {
      return null;
    } catch (_) {
      return null;
    }
  }

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

  Future<List<Map<String, dynamic>>> openRequests() async {
    if (!_available) return [];
    try {
      final snapshot = await firestore
          .collection('requests')
          .where('status', whereIn: const ['pending', 'offered'])
          .limit(100)
          .get();
      return snapshot.docs.map((doc) => <String, dynamic>{
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (_) { return []; }
  }

  Future<List<Map<String, dynamic>>> offersForRequest(String requestId) async {
    if (!_available) return [];
    try {
      final snapshot = await firestore
          .collection('offers')
          .where('request_id', isEqualTo: requestId)
          .get();
      return snapshot.docs.map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id}).toList();
    } catch (_) { return []; }
  }

  Future<List<Map<String, dynamic>>> ordersForCurrentUser() async {
    if (!_available || uid == null) return [];
    try {
      final snapshots = await Future.wait([
        firestore.collection('orders').where('customer_uid', isEqualTo: uid).get(),
        firestore.collection('orders').where('provider_uid', isEqualTo: uid).get(),
      ]);
      final byId = <String, Map<String, dynamic>>{};
      for (final snapshot in snapshots) {
        for (final doc in snapshot.docs) {
          byId[doc.id] = <String, dynamic>{...doc.data(), 'id': doc.id};
        }
      }
      return byId.values.toList();
    } catch (_) { return []; }
  }

  /// Atomically claims an SOS request. This prevents two providers on
  /// different phones from accepting the same urgent work.
  Future<Map<String, dynamic>?> claimSosRequest(
    String requestId,
    Map<String, dynamic> provider,
  ) async {
    if (!_available || uid == null) return null;
    try {
      return await firestore.runTransaction((transaction) async {
        final ref = firestore.collection('requests').doc(requestId);
        final snapshot = await transaction.get(ref);
        final data = snapshot.data();
        if (!snapshot.exists || data == null || data['is_sos'] != true || data['status'] != 'pending') return null;
        final deadline = DateTime.tryParse(data['sos_expires_at']?.toString() ?? '');
        if (deadline == null || !DateTime.now().isBefore(deadline)) return null;
        final accepted = <String, dynamic>{
          ...data,
          ...provider,
          'provider_uid': uid,
          'status': 'Elfogadva',
          'sos_accepted_at': DateTime.now().toIso8601String(),
          'updated_at': FieldValue.serverTimestamp(),
        };
        transaction.update(ref, accepted);
        transaction.set(firestore.collection('orders').doc(requestId), accepted);
        return accepted;
      });
    } catch (_) { return null; }
  }
}
