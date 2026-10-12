import '../widgets/taki_screen_header.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/taki_app_bar.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../services/device_workflow.dart';
import '../widgets/branded_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _pushKey = 'notify_push';
  static const _emailKey = 'notify_email';

  bool push = true;
  bool email = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      push = sp.getBool(_pushKey) ?? true;
      email = sp.getBool(_emailKey) ?? true;
    });
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    if (push && !await DeviceWorkflow.permission('notificationPermission')) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A telefon nem engedélyezte az értesítéseket.'),
          ),
        );
    }
    await sp.setBool(_pushKey, push);
    await sp.setBool(_emailKey, email);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Beállítások elmentve')));
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const TakiScreenHeader(
          title: 'Kijelentkezés',
          icon: Icons.info_outline_rounded,
        ),
        content: const Text('Biztosan ki szeretnél jelentkezni?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kijelentkezés'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('session_active', false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TakiAppBar(title: const Text('Beállítások')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TakiPanel(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: const Text('Előfizetések'),
                  subtitle: const Text('Megrendelői és szolgáltatói csomag'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/subscriptions'),
                ),
              ),
              const SizedBox(height: 8),
              TakiPanel(
                padding: EdgeInsets.zero,
                color: takiCardMint,
                child: SwitchListTile(
                  value: push,
                  title: const Text('Push értesítések'),
                  onChanged: (v) => setState(() => push = v),
                ),
              ),
              const SizedBox(height: 8),
              TakiPanel(
                padding: EdgeInsets.zero,
                color: takiCardYellow,
                child: SwitchListTile(
                  value: email,
                  title: const Text('Email értesítések'),
                  onChanged: (v) => setState(() => email = v),
                ),
              ),
              const SizedBox(height: 8),
              TakiPanel(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Saját naptár kapcsolata'),
                  subtitle: const Text(
                    'Automatikus hozzáadás be- és kikapcsolása',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.pushNamed(context, '/calendar_connection'),
                ),
              ),
              const SizedBox(height: 8),
              TakiPanel(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: takiCardYellow,
                child: ListTile(
                  leading: const Icon(Icons.logout, color: takiTealDark),
                  title: const Text('Kijelentkezés'),
                  subtitle: const Text(
                    'Az adataid megmaradnak ezen az eszközön.',
                  ),
                  onTap: _logout,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => showDeleteAccountDialog(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Profil törlése'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _save, child: const Text('Mentés')),
            ],
          ),
        ),
      ),
    );
  }
}
