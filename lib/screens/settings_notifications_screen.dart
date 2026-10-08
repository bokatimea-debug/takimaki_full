import '../widgets/taki_app_bar.dart';
import 'package:flutter/material.dart';

import '../models/settings.dart';
import '../theme.dart';
import '../widgets/branded_background.dart';

class SettingsNotificationsScreen extends StatefulWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  State<SettingsNotificationsScreen> createState() =>
      _SettingsNotificationsScreenState();
}

class _SettingsNotificationsScreenState
    extends State<SettingsNotificationsScreen> {
  final s = NotificationSettings.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TakiAppBar(title: const Text('Értesítések')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          const TakiHeroHeader(
            eyebrow: 'Maradj naprakész',
            title: 'Te döntöd el,\nmiről szóljunk',
            subtitle:
                'Csak a valóban fontos ajánlatokról és változásokról küldünk értesítést.',
            icon: Icons.notifications_active_rounded,
            accent: takiOrange,
          ),
          const SizedBox(height: 18),
          TakiPanel(
            child: Column(
              children: [
                _NotificationTile(
                  icon: Icons.phone_android_rounded,
                  color: takiTeal,
                  title: 'Push értesítések',
                  subtitle: 'Új ajánlatok és rendelési státuszok',
                  value: s.pushEnabled,
                  onChanged: (v) => setState(() => s.pushEnabled = v),
                ),
                const Divider(height: 28),
                _NotificationTile(
                  icon: Icons.alternate_email_rounded,
                  color: takiOrange,
                  title: 'Email értesítések',
                  subtitle: 'Visszaigazolások és fontos összefoglalók',
                  value: s.emailEnabled,
                  onChanged: (v) => setState(() => s.emailEnabled = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const TakiPanel(
            color: takiYellowSoft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user_outlined, color: takiNavy),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'A rendszerüzeneteket és a biztonsági értesítéseket mindig elküldjük.',
                    style: TextStyle(height: 1.4, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(icon, color: color),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF617577), height: 1.3),
            ),
          ],
        ),
      ),
      Switch(value: value, onChanged: onChanged),
    ],
  );
}
