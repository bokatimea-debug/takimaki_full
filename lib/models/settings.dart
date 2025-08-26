// lib/models/settings.dart
class NotificationSettings {
  static final NotificationSettings instance = NotificationSettings._();
  NotificationSettings._();

  bool pushEnabled = true;   // alap: be
  bool emailEnabled = true;  // alap: be
}
