// lib/models/chat.dart
class ChatMessage {
  final String id;
  final String author; // "me" | "other"
  final String text;
  final DateTime at;

  ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.at,
  });
}

class ChatStore {
  static final ChatStore instance = ChatStore._();
  ChatStore._();

  // egyetlen „szoba” demóhoz
  final List<ChatMessage> _messages = [];

  // 30 napos retention
  static const Duration retention = Duration(days: 30);

  List<ChatMessage> get messages {
    _purgeOld();
    return List.unmodifiable(_messages);
  }

  void send(String author, String text) {
    _purgeOld();
    _messages.add(ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      author: author,
      text: text,
      at: DateTime.now(),
    ));
  }

  void seedDemoIfEmpty() {
    if (_messages.isNotEmpty) return;
    final now = DateTime.now();
    _messages.addAll([
      ChatMessage(id: '1', author: 'other', text: 'Szia! Pontosítsuk az időpontot?', at: now.subtract(const Duration(minutes: 35))),
      ChatMessage(id: '2', author: 'me', text: 'Szia! Nekem 10:00 megfelel.', at: now.subtract(const Duration(minutes: 30))),
      ChatMessage(id: '3', author: 'other', text: 'Rendben, 10:00-ra megyek. Köszönöm!', at: now.subtract(const Duration(minutes: 25))),
    ]);
  }

  void _purgeOld() {
    final cutoff = DateTime.now().subtract(retention);
    _messages.removeWhere((m) => m.at.isBefore(cutoff));
  }
}
