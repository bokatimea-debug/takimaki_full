import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

Future<void> seedTestUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);

  await docRef.set({
    "displayName": user.displayName ?? "Teszt Felhasználó",
    "photoUrl": user.photoURL ?? "https://picsum.photos/200", // ideiglenes kép
    "bio": "Ez egy rövid bemutatkozó szöveg.",
    "stats": {
      "provider_successful_orders": 2,
      "customer_successful_orders": 3,
    }
  }, SetOptions(merge: true));
}
