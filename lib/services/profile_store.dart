import "dart:typed_data";

/// Egyszerű, memóriában élő profil tároló.
/// (Ha majd tartósítani akarjuk, ide kerül a SharedPreferences/Isar stb.)
class ProfileStore {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  final customer = _Profile();
  final provider = _Profile();
}

class _Profile {
  String bio = "";
  String weekdayHours = ""; // "H–P 9:00–18:00"
  String weekendHours = ""; // "Szo–V 10:00–16:00"
  Uint8List? photoBytes;
}
