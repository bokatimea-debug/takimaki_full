import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    setState(() {
      push = sp.getBool(_pushKey) ?? true;
      email = sp.getBool(_emailKey) ?? true;
    });
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_pushKey, push);
    await sp.setBool(_emailKey, email);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Beállítások elmentve')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beállítások')),
      body: ListView(
        children: [
          SwitchListTile(
            value: push,
            title: const Text('Push értesítések'),
            onChanged: (v) => setState(() => push = v),
          ),
          SwitchListTile(
            value: email,
            title: const Text('Email értesítések'),
            onChanged: (v) => setState(() => email = v),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _save,
              child: const Text('Mentés'),
            ),
          ),
        ],
      ),
    );
  }
}
