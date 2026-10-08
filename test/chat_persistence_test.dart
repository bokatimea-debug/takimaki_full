import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takimaki_full/data/mock_data.dart';
import 'package:takimaki_full/services/local_chat_store.dart';
import 'package:takimaki_full/screens/chat_screens.dart';
import 'profile_photo_test.dart' show photoFixture;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    MockData.threads = [];
  });

  test('Peer name, role and bytes survive serialization', () async {
    MockData.threads = [
      MockThread(
          id: 'peer',
          peerName: 'Nagy Petra',
          peerRole: 'provider',
          viewRole: 'customer',
          peerPhotoB64: photoFixture,
          messages: [])
    ];
    await LocalChatStore.save();
    MockData.threads = [];
    await LocalChatStore.load();
    expect(MockData.threads.single.peerName, 'Nagy Petra');
    expect(MockData.threads.single.peerRole, 'provider');
    expect(MockData.threads.single.peerPhotoB64, photoFixture);
  });

  test('Peer path is converted to durable bytes before cache cleanup',
      () async {
    final dir = await Directory.systemTemp.createTemp('takimaki_peer_test_');
    addTearDown(() => dir.delete(recursive: true));
    final file = await File('${dir.path}/peer.png')
        .writeAsBytes(base64Decode(photoFixture));
    MockData.threads = [
      MockThread(
          id: 'peer', peerName: 'Petra', peerPhotoPath: file.path, messages: [])
    ];
    await LocalChatStore.save();
    await file.delete();
    MockData.threads = [];
    await LocalChatStore.load();
    expect(MockData.threads.single.peerPhotoB64, photoFixture);
  });

  test(
      'Role switch reads the partner snapshot and clears the previous partner photo',
      () async {
    SharedPreferences.setMockInitialValues({
      'active_role': 'customer',
      'profile_photo_b64': photoFixture,
      'customer_orders': jsonEncode([
        {
          'request_id': 'one',
          'provider_name': 'Petra',
          'provider_photo_b64': photoFixture
        }
      ]),
      'provider_orders': jsonEncode([
        {'request_id': 'one', 'customer': 'Tímea'}
      ]),
    });
    MockData.ensureThread(requestId: 'one', peerName: 'Previous');
    await LocalChatStore.refreshPeers();
    expect(MockData.threads.single.peerName, 'Petra');
    expect(MockData.threads.single.peerPhotoB64, photoFixture);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_role', 'provider');
    await LocalChatStore.refreshPeers();
    expect(MockData.threads.single.peerName, 'Tímea');
    expect(MockData.threads.single.peerRole, 'customer');
    expect(MockData.threads.single.peerPhotoB64, isNull);
  });

  testWidgets(
      'Missing partner photo uses initials, never the own photo or mascot',
      (tester) async {
    SharedPreferences.setMockInitialValues({'profile_photo_b64': photoFixture});
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ChatPeerAvatar(
                thread: MockThread(
                    id: 'peer', peerName: 'Nagy Petra', messages: [])))));
    await tester.pumpAndSettle();
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isNull);
    expect(find.text('P'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
