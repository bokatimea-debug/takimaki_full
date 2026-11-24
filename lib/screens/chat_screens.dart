import '../widgets/taki_app_bar.dart';

import "dart:io";
import 'dart:async';

import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import "package:shared_preferences/shared_preferences.dart";

import "../utils/profile_photo_loader.dart";

import "../data/mock_data.dart";
import "../services/local_chat_store.dart";
import '../services/remote_chat_store.dart';
import '../services/remote_media_store.dart';
import "../theme.dart";
import "../widgets/branded_background.dart";

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    LocalChatStore.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final threads = MockData.threads;
    return Scaffold(
      appBar: TakiAppBar(title: const Text("Üzenetek")),
      body: BrandedBackground(
        child: threads.isEmpty
          ? const TakiEmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'Még nincs üzeneted',
              text: 'Elfogadott ajánlat után itt tudtok egyeztetni.',
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                18,
                12,
                18,
                MediaQuery.paddingOf(context).bottom + 28,
              ),
              itemCount: threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final t = threads[i];
                final last = t.messages.isNotEmpty ? t.messages.last : null;
                return Material(
                  color: i.isEven ? takiMint : takiYellowSoft,
                  borderRadius: BorderRadius.circular(24),
                  elevation: 2,
                  shadowColor: takiTealDark.withOpacity(.10),
                  child: ListTile(
                    minVerticalPadding: 18,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    leading: ChatPeerAvatar(thread: t, radius: 25),
                    title: Text(
                      t.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        last?.text ?? "Indíts beszélgetést",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(last != null ? _ago(last.ts) : ""),
                        const SizedBox(height: 7),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: takiTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await LocalChatStore.markThreadRead(
                        prefs.getString('active_role') ?? 'customer',
                        t.id,
                      );
                      if (!context.mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatThreadScreen(threadId: t.id),
                        ),
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                );
              },
            ),
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
  StreamSubscription<List<Map<String, dynamic>>>? _remoteMessages;

  @override
  void initState() {
    super.initState();
    _thread = MockData.threads.firstWhere((t) => t.id == widget.threadId);
    LocalChatStore.load().then((_) {
      if (!mounted) return;
      setState(
        () => _thread = MockData.threads.firstWhere(
          (t) => t.id == widget.threadId,
        ),
      );
    });
    _remoteMessages = RemoteChatStore.messages(widget.threadId).listen((messages) {
      if (!mounted) return;
      var changed = false;
      for (final remote in messages) {
        if (_thread.messages.any((message) => message.id == remote['id'])) continue;
        _thread.messages.add(MockMessage(
          id: remote['id'] as String,
          threadId: _thread.id,
          from: remote['from'] as String,
          text: remote['text'] as String,
          mediaUrl: remote['mediaUrl'] as String?,
          ts: remote['ts'] as DateTime,
        ));
        changed = true;
      }
      if (changed) {
        _thread.messages.sort((a, b) => a.ts.compareTo(b.ts));
        LocalChatStore.save();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _remoteMessages?.cancel();
    _input.dispose();
    super.dispose();
  }

  Future<void> _send([String? mediaUrl]) async {
    final text = _input.text.trim();
    if (text.isEmpty && (mediaUrl == null || mediaUrl.isEmpty)) return;
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _thread.messages.add(
        MockMessage(
          id: messageId,
          threadId: _thread.id,
          from: "Én",
          text: text,
          mediaUrl: mediaUrl,
          ts: DateTime.now(),
        ),
      );
    });
    _input.clear();
    await LocalChatStore.save();
    final sent = await RemoteChatStore.send(
      threadId: _thread.id,
      clientMessageId: messageId,
      text: text,
      mediaUrl: mediaUrl,
    );
    if (!sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Az üzenet ezen a telefonon elmentve. Internetkapcsolat után küldd el újra.'),
      ));
    }
  }

  Future<void> _sendImage(ImageSource source) async {
    try {
      final url = await RemoteMediaStore.pickAndUpload(
        collection: 'chat_media',
        relativePath: _thread.id,
        source: source,
      );
      if (url != null) await _send(url);
    } on StateError catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message.toString())));
    }
  }

  Future<void> _chooseImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Fotó készítése'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Kép kiválasztása'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source != null) await _sendImage(source);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TakiAppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ChatPeerAvatar(thread: _thread, radius: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _thread.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Beszélgetés',
                    style: TextStyle(
                      fontSize: 12,
                      color: takiTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: BrandedBackground(
        child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              itemCount: _thread.messages.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Ma',
                            style: TextStyle(
                              color: takiMutedText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  );
                }
                final m = _thread.messages[i - 1];
                final me = m.from == "Én";
                return Align(
                  alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * .76,
                    ),
                    decoration: BoxDecoration(
                      color: me ? takiTeal : takiFieldSurface,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14083B46),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(me ? 20 : 5),
                        bottomRight: Radius.circular(me ? 5 : 20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: me
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (m.mediaUrl != null && m.mediaUrl!.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              m.mediaUrl!,
                              width: 210,
                              height: 210,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(
                                width: 210,
                                height: 120,
                                child: Center(child: Icon(Icons.broken_image_outlined)),
                              ),
                            ),
                          ),
                          if (m.text.isNotEmpty) const SizedBox(height: 8),
                        ],
                        Text(
                          m.text,
                          style: TextStyle(
                            color: me ? Colors.white : takiTealDark,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dt(context, m.ts),
                              style: TextStyle(
                                fontSize: 11,
                                color: me ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            if (me) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.done_all_rounded,
                                size: 15,
                                color: Colors.white70,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 6, 12, 16),
              padding: const EdgeInsets.fromLTRB(6, 5, 5, 5),
              decoration: BoxDecoration(
                color: takiFieldSurface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x20083B46),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Kép küldése',
                    onPressed: _chooseImage,
                    icon: const Icon(Icons.image_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: "Írj üzenetet…",
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    tooltip: 'Küldés',
                    style: IconButton.styleFrom(
                      backgroundColor: takiOrange,
                      foregroundColor: takiNavy,
                    ),
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

/// A partner's persisted photo, with a neutral monogram when unavailable.
/// This deliberately never consults the signed-in user's photo preferences.
class ChatPeerAvatar extends StatelessWidget {
  final MockThread thread;
  final double radius;
  const ChatPeerAvatar({super.key, required this.thread, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final bytes = ProfilePhotoLoader.decodePhoto(thread.peerPhotoB64);
    final path = thread.peerPhotoPath;
    ImageProvider? photo;
    if (bytes != null) {
      photo = MemoryImage(bytes);
    } else if (path != null && path.isNotEmpty && File(path).existsSync()) {
      photo = FileImage(File(path));
    }
    final names = thread.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2);
    final initials = names
        .map((word) => word.characters.first)
        .join()
        .toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: takiMint,
      foregroundColor: takiNavy,
      backgroundImage: photo,
      child: photo == null
          ? Text(
              initials.isEmpty ? '?' : initials,
              style: TextStyle(
                fontSize: radius * .65,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}
