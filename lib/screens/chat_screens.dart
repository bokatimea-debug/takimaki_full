import "package:flutter/material.dart";
import "../data/mock_data.dart";

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = MockData.threads;
    return Scaffold(
      appBar: AppBar(title: const Text("Üzenetek")),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: threads.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final t = threads[i];
          final last = t.messages.isNotEmpty ? t.messages.last : null;
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(t.peerName),
              subtitle: Text(last?.text ?? "—"),
              trailing: Text(last != null ? _ago(last.ts) : ""),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatThreadScreen(threadId: t.id)));
              },
            ),
          );
        },
      ),
    );
  }

  String _ago(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 60) return "${diff.inMinutes}p";
    if (diff.inHours < 24) return "${diff.inHours}ó";
    return "${diff.inDays} nap";
  }
}

class ChatThreadScreen extends StatefulWidget {
  final String threadId;
  const ChatThreadScreen({super.key, required this.threadId});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late MockThread _thread;
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    _thread = MockData.threads.firstWhere((t) => t.id == widget.threadId);
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _thread.messages.add(MockMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        threadId: _thread.id,
        from: "Én",
        text: text,
        ts: DateTime.now(),
      ));
    });
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_thread.peerName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _thread.messages.length,
              itemBuilder: (_, i) {
                final m = _thread.messages[i];
                final me = m.from == "Én";
                return Align(
                  alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: me ? Colors.teal.withOpacity(.15) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(m.text),
                        const SizedBox(height: 2),
                        Text(dt(context, m.ts), style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(
                      hintText: "Írj üzenetet…",
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                IconButton(onPressed: _send, icon: const Icon(Icons.send))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
