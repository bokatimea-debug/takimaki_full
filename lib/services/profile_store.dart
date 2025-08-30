// lib/services/profile_store.dart
import 'dart:typed_data';

class ProfileData {
  Uint8List? photoBytes;
  String bio = '';
  String weekdayHours = ''; // pl. "H–P 9–18"
  String weekendHours = ''; // pl. "Szo–V 10–16"

  // statisztikák (dummy, lehet később backend)
  double rating = 4.7;
  int successCount = 24;
}

class ProfileStore {
  ProfileStore._();
  static final instance = ProfileStore._();

  final provider = ProfileData();
  final customer = ProfileData();
}
