import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

/// Egységes profilkép-URL feloldás:
/// 1) Firestore users/{uid}.photoUrl
/// 2) Auth user.photoURL
/// 3) null -> fallback ikon a UI-ban
Future<String?> loadProfilePhotoUrl(String uid) async {
  try {
    final userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    String? url = (userDoc.data()?["photoUrl"] as String?)?.trim();
    url ??= FirebaseAuth.instance.currentUser?.photoURL;
    if (url == null || url.isEmpty) return null;

    // Cache-bontás: ha van updatedAt, fűzzük hozzá
    final updatedAt = userDoc.data()?["updatedAt"];
    if (updatedAt is Timestamp) {
      final t = updatedAt.seconds;
      if (!url.contains("?")) return "$url?t=$t";
      return "$url&ts=$t";
    }
    return url;
  } catch (_) {
    // Ha bármilyen hiba van (pl. offline), ne dőljön el a képernyő
    return FirebaseAuth.instance.currentUser?.photoURL;
  }
}
