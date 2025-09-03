import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subscription.dart';

class SubscriptionService {
  static Future<SubscriptionState> loadForRole(String role) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = userDoc.data() ?? {};
    final subs = (data['subscriptions'] ?? {}) as Map<String, dynamic>;
    final roleSub = (subs[role] ?? {}) as Map<String, dynamic>;
    final isActive = (roleSub['isActive'] ?? false) as bool;
    final ts = roleSub['activeUntil'];
    DateTime? until;
    if (ts is Timestamp) until = ts.toDate();

    final stats = (data['stats'] ?? {}) as Map<String, dynamic>;
    final successfulCount = (stats['${role}_successful_orders'] ?? 0) as int;

    return SubscriptionState(
      isActive: isActive,
      activeUntil: until,
      role: role,
      successfulCount: successfulCount,
    );
  }

  static Future<void> markSubscribed(String role, DateTime until) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await userRef.set({
      'subscriptions': {
        role: {
          'isActive': true,
          'activeUntil': Timestamp.fromDate(until),
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }
    }, SetOptions(merge: true));
  }
}
