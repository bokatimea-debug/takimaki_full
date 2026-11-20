import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_backend.dart';

/// Uploads compressed evidence images outside Firestore. Firestore stores only
/// the resulting reference/URL; no Base64 image data is persisted there.
class RemoteMediaStore {
  static Future<String?> pickAndUpload({
    required String folder,
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
    final ref = FirebaseStorage.instance.ref(
      '$folder/${backend.uid}/$timestamp-${image.name}',
    );
    await ref.putFile(File(image.path), SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
