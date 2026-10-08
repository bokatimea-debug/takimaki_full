import '../utils/public_name.dart';

import "package:flutter/material.dart";

class MockOffer {
  final String id;
  final String service;
  final String providerName;
  final String district; // pl. XIII.
  final DateTime dateTime;
  final int priceFt;

  MockOffer({
    required this.id,
    required this.service,
    required this.providerName,
    required this.district,
    required this.dateTime,
    required this.priceFt,
  });
}

class MockMessage {
  final String id;
  final String threadId;
  final String from;
  final String text;
  final DateTime ts;

  MockMessage({
    required this.id,
    required this.threadId,
    required this.from,
    required this.text,
    required this.ts,
  });

  factory MockMessage.fromJson(Map<String, dynamic> json) => MockMessage(
    id: json['id'] as String,
    threadId: json['threadId'] as String,
    from: json['from'] as String,
    text: json['text'] as String,
    ts: DateTime.parse(json['ts'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'threadId': threadId,
    'from': from,
    'text': text,
    'ts': ts.toIso8601String(),
  };
}

class MockThread {
  final String id;
  String peerName;
  String? peerFirstName;
  String get displayName => publicName(peerName, firstName: peerFirstName);
  String? peerPhotoB64;
  String? peerPhotoPath;
  String? peerRole;
  String? peerId;
  String? viewRole;
  final List<MockMessage> messages;

  MockThread({
    required this.id,
    required this.peerName,
    this.peerFirstName,
    this.peerPhotoB64,
    this.peerPhotoPath,
    this.peerRole,
    this.peerId,
    this.viewRole,
    required this.messages,
  });

  factory MockThread.fromJson(Map<String, dynamic> json) => MockThread(
    id: json['id'] as String,
    peerName: json['peerName'] as String,
    peerFirstName: json['peerFirstName'] as String?,
    peerPhotoB64: json['peerPhotoB64'] as String?,
    peerPhotoPath: json['peerPhotoPath'] as String?,
    peerRole: json['peerRole'] as String?,
    peerId: json['peerId'] as String?,
    viewRole: json['viewRole'] as String?,
    messages: (json['messages'] as List<dynamic>)
        .map(
          (item) =>
              MockMessage.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'peerName': peerName,
    'peerFirstName': peerFirstName,
    'peerPhotoB64': peerPhotoB64,
    'peerPhotoPath': peerPhotoPath,
    'peerRole': peerRole,
    'peerId': peerId,
    'viewRole': viewRole,
    'messages': messages.map((message) => message.toJson()).toList(),
  };
}

class MockData {
  static List<MockOffer> offers = [
    MockOffer(
      id: "of1",
      service: "Általános takarítás",
      providerName: "Tisztacsillag Kft.",
      district: "XIII",
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
      priceFt: 12000,
    ),
    MockOffer(
      id: "of2",
      service: "Nagytakarítás",
      providerName: "VillámClean",
      district: "XI",
      dateTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
      priceFt: 28000,
    ),
    MockOffer(
      id: "of3",
      service: "Villanyszerelés",
      providerName: "Fény Mester Bt.",
      district: "VIII",
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 14)),
      priceFt: 18000,
    ),
  ];

  static List<MockThread> threads = [
    MockThread(
      id: "th1",
      peerName: "Tisztacsillag Kft.",
      messages: [
        MockMessage(
          id: "m1",
          threadId: "th1",
          from: "Ők",
          text: "Szia! A holnapi időpont jó?",
          ts: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        MockMessage(
          id: "m2",
          threadId: "th1",
          from: "Én",
          text: "Igen, 9:00-ra várlak.",
          ts: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
      ],
    ),
    MockThread(
      id: "th2",
      peerName: "VillámClean",
      messages: [
        MockMessage(
          id: "m1",
          threadId: "th2",
          from: "Ők",
          text: "Küldtem ajánlatot, ránézel?",
          ts: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
    MockThread(
      id: "th3",
      peerName: "Fény Mester Bt.",
      messages: [
        MockMessage(
          id: "m1",
          threadId: "th3",
          from: "Én",
          text: "Köszönöm, elfogadtam.",
          ts: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        ),
      ],
    ),
  ];

  static MockThread ensureThread({
    required String requestId,
    required String peerName,
    String? peerFirstName,
    String? peerPhotoB64,
    String? peerPhotoPath,
    String? peerRole,
    String? peerId,
    String? viewRole,
  }) {
    final id = 'request_$requestId';
    for (final thread in threads) {
      if (thread.id == id) {
        // Switching roles changes who the conversation partner is. Do not keep
        // a photo from the previous partner when the new one has no photo.
        thread.peerName = peerName;
        thread.peerFirstName = peerFirstName;
        thread.peerPhotoB64 = peerPhotoB64;
        thread.peerPhotoPath = peerPhotoPath;
        thread.peerRole = peerRole;
        thread.peerId = peerId;
        thread.viewRole = viewRole;
        return thread;
      }
    }
    final thread = MockThread(
      id: id,
      peerName: peerName,
      peerFirstName: peerFirstName,
      peerPhotoB64: peerPhotoB64,
      peerPhotoPath: peerPhotoPath,
      peerRole: peerRole,
      peerId: peerId,
      viewRole: viewRole,
      messages: [],
    );
    threads.add(thread);
    return thread;
  }
}

String ft(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final left = s.length - i;
    b.write(s[i]);
    if (left > 1 && left % 3 == 1) b.write(" ");
  }
  return "$b Ft";
}

String dt(BuildContext c, DateTime d) =>
    "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')} "
    "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
