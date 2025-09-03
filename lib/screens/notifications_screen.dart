import "package:flutter/material.dart";
import "../services/notifications_service.dart";

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> items = [];
  @override
  void initState(){ super.initState(); _load(); }
  Future<void> _load() async { final l = await NotificationsService.list(); if (mounted) setState(()=> items=l); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Értesítések")),
      body: items.isEmpty ? const Center(child: Text("Nincs értesítés")) :
        ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __)=> const Divider(height:1),
          itemBuilder: (_, i){
            final it = items[i];
            return ListTile(
              title: Text(it.title),
              subtitle: Text("${it.body}\n${it.ts.toLocal()}"),
              isThreeLine: true,
            );
          }
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await NotificationsService.push(NotificationItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: "Teszt értesítés",
            body: "Ez egy helyi (mock) értesítés.",
          ));
          await _load();
        },
        label: const Text("Teszt értesítés"),
        icon: const Icon(Icons.notification_important),
      ),
    );
  }
}
