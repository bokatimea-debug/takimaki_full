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

  Map<String, dynamic> toJson() => {
    'id': id,
    'thread_id': threadId,
    'from': from,
    'text': text,
    'ts': ts.toIso8601String(),
  };

  factory MockMessage.fromJson(Map<String, dynamic> json) => MockMessage(
    id: json['id']?.toString() ?? '',
    threadId: json['thread_id']?.toString() ?? '',
    from: json['from']?.toString() ?? '',
    text: json['text']?.toString() ?? '',
    ts: DateTime.tryParse(json['ts']?.toString() ?? '') ?? DateTime.now(),
  );
}

class MockThread {
  final String id;
  final String peerName;
  final List<MockMessage> messages;

  MockThread({
    required this.id,
    required this.peerName,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'peer_name': peerName,
    'messages': messages.map((message) => message.toJson()).toList(),
  };

  factory MockThread.fromJson(Map<String, dynamic> json) => MockThread(
    id: json['id']?.toString() ?? '',
    peerName: json['peer_name']?.toString() ?? 'Partner',
    messages: (json['messages'] as List? ?? const [])
        .map(
          (message) =>
              MockMessage.fromJson(Map<String, dynamic>.from(message as Map)),
        )
        .toList(),
  );
}

class MockData {
  static MockThread ensureThread({
    required String requestId,
    required String peerName,
  }) {
    final threadId = 'th_$requestId';
    final existing = threads.where((thread) => thread.id == threadId);
    if (existing.isNotEmpty) return existing.first;
    final thread = MockThread(
      id: threadId,
      peerName: peerName,
      messages: [
        MockMessage(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          threadId: threadId,
          from: 'Rendszer',
          text: 'A rendelés elfogadva. Mostantól üzenhettek egymásnak.',
          ts: DateTime.now(),
        ),
      ],
    );
    threads.insert(0, thread);
    return thread;
  }

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
      service: "Bútorszerelés",
      providerName: "Bútor Mester Bt.",
      district: "VIII",
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 14)),
      priceFt: 18000,
    ),
  ];

  static List<MockThread> threads = [];
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
