import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_backend.dart';

/// Uploads compressed evidence images outside Firestore. Firestore stores only
/// the resulting reference/URL; no Base64 image data is persisted there.
class RemoteMediaStore {
  static Future<String?> pickAndUpload({
    required String collection,
    required String relativePath,
    ImageSource source = ImageSource.camera,
  }) async {
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (image == null) return null;
    final backend = FirebaseBackend.instance;
    if (!backend.isAvailable || backend.uid == null) {
      throw StateError('A képfeltöltéshez internetkapcsolat és Firebase-bejelentkezés szükséges.');
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safePath = relativePath
        .split('/')
        .where((part) => part.trim().isNotEmpty && part != '.' && part != '..')
        .join('/');
    final ref = FirebaseStorage.instance.ref(
      '$collection/${backend.uid}/${safePath.isEmpty ? '' : '$safePath/'}$timestamp-${image.name}',
    );
    await ref.putFile(File(image.path), SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
