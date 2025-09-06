import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

Future<String?> loadProfilePhotoUrl(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    String? url = (doc.data()?["photoUrl"] as String?)?.trim();
    url ??= FirebaseAuth.instance.currentUser?.photoURL;
    if (url == null || url.isEmpty) return null;

    final updatedAt = doc.data()?["updatedAt"];
    if (updatedAt is Timestamp) {
      final t = updatedAt.seconds;
      return url.contains("?") ? "$url&ts=$t" : "$url?t=$t";
    }
    return url;
  } catch (_) {
    return FirebaseAuth.instance.currentUser?.photoURL;
  }
}
