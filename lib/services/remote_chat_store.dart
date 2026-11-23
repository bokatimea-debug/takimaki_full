import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_backend.dart';

/// Shared Firestore chat.  The local chat store remains an offline cache, but
/// a conversation created from a real order is shared between both accounts.
class RemoteChatStore {
  static Future<void> ensureThread({
    required String threadId,
    required String peerUid,
    required String peerName,
  }) async {
    final backend = FirebaseBackend.instance;
    final uid = backend.uid;
    if (!backend.isAvailable || uid == null || peerUid.isEmpty || peerUid == uid) return;
    await backend.firestore.collection('chats').doc(threadId).set({
      'participant_uids': [uid, peerUid],
      'participant_names': {uid: 'Én', peerUid: peerName},
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> send({
    required String threadId,
    required String text,
    String? mediaUrl,
  }) async {
    final backend = FirebaseBackend.instance;
    final uid = backend.uid;
    if (!backend.isAvailable || uid == null) return;
    final cleanText = text.trim();
    if (cleanText.isEmpty && (mediaUrl == null || mediaUrl.isEmpty)) return;
    final thread = backend.firestore.collection('chats').doc(threadId);
    final snapshot = await thread.get();
    if (!snapshot.exists) return;
    await thread.collection('messages').add({
      'sender_uid': uid,
      'text': cleanText,
      'media_url': mediaUrl,
      'created_at': FieldValue.serverTimestamp(),
      'client_created_at': DateTime.now().toIso8601String(),
    });
    await thread.set({'updated_at': FieldValue.serverTimestamp(), 'last_message': cleanText.isEmpty ? 'Kép' : cleanText}, SetOptions(merge: true));
  }

  static Stream<List<Map<String, dynamic>>> messages(String threadId) {
    final backend = FirebaseBackend.instance;
    final uid = backend.uid;
    if (!backend.isAvailable || uid == null) return const Stream.empty();
    return backend.firestore.collection('chats').doc(threadId).collection('messages')
        .orderBy('created_at')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          final timestamp = data['created_at'];
          return <String, dynamic>{
            'id': doc.id,
            'from': data['sender_uid'] == uid ? 'Én' : 'Partner',
            'text': data['text']?.toString() ?? '',
            'mediaUrl': data['media_url']?.toString(),
            'ts': timestamp is Timestamp
                ? timestamp.toDate()
                : DateTime.tryParse(data['client_created_at']?.toString() ?? '') ?? DateTime.now(),
          };
        }).toList());
  }
}
