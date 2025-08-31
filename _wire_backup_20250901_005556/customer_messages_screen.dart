// lib/screens/customer_messages_screen.dart
import "package:flutter/material.dart";
import "../services/demo_data.dart";

class CustomerMessagesScreen extends StatelessWidget {
  const CustomerMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = DemoMessages.threads;
    return Scaffold(
      appBar: AppBar(title: const Text("Üzenetek")),
      body: ListView.separated(
        itemCount: threads.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final t = threads[i];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(t["name"]!),
            subtitle: Text(t["last"]!, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(t["time"]!, style: const TextStyle(color: Colors.grey)),
            onTap: ()=> Navigator.pushNamed(context, "/chat", arguments: {"with": t["name"]}),
          );
        },
      ),
    );
  }
}
