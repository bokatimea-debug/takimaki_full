// lib/session.dart
class UserSession {
  static final UserSession instance = UserSession._();
  UserSession._();

  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  bool hasPhoto = false;

  bool get isRegistered =>
      (firstName != null && firstName!.trim().isNotEmpty && hasPhoto);

  void clear() {
    firstName = null;
    lastName = null;
    phone = null;
    email = null;
    hasPhoto = false;
  }
}
