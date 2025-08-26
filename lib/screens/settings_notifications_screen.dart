import 'package:flutter/material.dart';
import '../models/settings.dart';

class SettingsNotificationsScreen extends StatefulWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  State<SettingsNotificationsScreen> createState() => _SettingsNotificationsScreenState();
}

class _SettingsNotificationsScreenState extends State<SettingsNotificationsScreen> {
  final s = NotificationSettings.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Értesítések')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Push értesítések'),
            value: s.pushEnabled,
            onChanged: (v) => setState(() => s.pushEnabled = v),
            subtitle: const Text('Ajánlatok, státuszok, felfüggesztések'),
          ),
          const Divider(height: 0),
          SwitchListTile(
            title: const Text('Email értesítések'),
            value: s.emailEnabled,
            onChanged: (v) => setState(() => s.emailEnabled = v),
            subtitle: const Text('Ajánlatok és visszaigazolások emailben'),
          ),
        ],
      ),
    );
  }
}
