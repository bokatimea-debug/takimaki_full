--- provider_offer_reply_screen.dart PATCH ---
@@ class _ProviderOfferReplyScreenState extends State<ProviderOfferReplyScreen> {
   void _sendOffer() async {
-    // TODO: implement
+    final offerId = widget.offerId;
+    await FirebaseFirestore.instance.collection("offers").doc(offerId).update({
+      "status":"accepted",
+      "price": _priceController.text,
+    });
+    await FirebaseFirestore.instance.collection("bookings").add({
+      "offerId": offerId,
+      "provider": FirebaseAuth.instance.currentUser!.uid,
+      "created": FieldValue.serverTimestamp()
+    });
+    if (!mounted) return;
+    Navigator.pop(context);
   }
}
