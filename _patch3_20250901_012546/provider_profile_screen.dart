import '../utils/profile_photo_loader.dart';
--- provider_profile_screen.dart PATCH ---
@@ class _S extends State<ProviderProfileScreen> {
-  ImageProvider? _photo;
+  ImageProvider? _photo;

   @override
   void initState(){ super.initState(); _load(); -    _load();
+    _load();
+    _loadPhoto();
   }
+
+  Future<void> _loadPhoto() async {
+    final data = await ProfilePhotoLoader.load("provider");
+    setState(()=> _photo=data);
+  }
}

