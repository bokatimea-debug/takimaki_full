// lib/screens/chat_demo_screen.dart
import "package:flutter/material.dart";

class ChatDemoScreen extends StatefulWidget {
  const ChatDemoScreen({super.key});
  @override
  State<ChatDemoScreen> createState() => _ChatDemoScreenState();
}

class _ChatDemoScreenState extends State<ChatDemoScreen> {
  final _ctrl = TextEditingController();
  final List<_Msg> _messages = [
    _Msg(text: "Üdv! Mikor érkeznek holnap?", me: false, ts: DateTime.now()),
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _send(){
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(()=> _messages.add(_Msg(text: t, me: true, ts: DateTime.now())));
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final who = (ModalRoute.of(context)?.settings.arguments as Map?)?["with"] ?? "Partner";
    return Scaffold(
      appBar: AppBar(title: Text("Chat – $who")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final align = m.me ? Alignment.centerRight : Alignment.centerLeft;
                final color = m.me ? Colors.teal.shade100 : Colors.grey.shade200;
                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: "Írj üzenetet..."), onSubmitted: (_)=>_send(),)),
                const SizedBox(width: 8),
                IconButton(onPressed: _send, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  _Msg({required this.text, required this.me, required this.ts});
  final String text; final bool me; final DateTime ts;
}
