--- provider_services_screen.dart PATCH ---
@@ class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
-  final List<String> _services = [];
+  final List<String> _services = [];
+
+  @override
+  void initState() {
+    super.initState();
+    _load();
+  }
+
+  Future<void> _load() async {
+    final snap = await FirebaseFirestore.instance
+        .collection("services")
+        .where("provider", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
+        .get();
+    setState(()=> _services = snap.docs.map((d)=> d["name"] as String).toList());
+  }
}
