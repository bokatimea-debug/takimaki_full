--- customer_profile_screen.dart PATCH ---
@@ class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
-  ImageProvider? _photo;
+  ImageProvider? _photo;

   @override
   void initState() {
     super.initState();
-    _load();
+    _load();
+    _loadPhoto();
   }
+
+  Future<void> _loadPhoto() async {
+    final data = await ProfilePhotoLoader.load("customer");
+    setState(()=> _photo=data);
+  }
}
