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
}

class MockThread {
  final String id;
  final String peerName;
  final List<MockMessage> messages;

  MockThread({required this.id, required this.peerName, required this.messages});
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
        MockMessage(id: "m1", threadId: "th1", from: "Ők", text: "Szia! A holnapi időpont jó?", ts: DateTime.now().subtract(const Duration(minutes: 30))),
        MockMessage(id: "m2", threadId: "th1", from: "Én", text: "Igen, 9:00-ra várlak.", ts: DateTime.now().subtract(const Duration(minutes: 12))),
      ],
    ),
    MockThread(
      id: "th2",
      peerName: "VillámClean",
      messages: [
        MockMessage(id: "m1", threadId: "th2", from: "Ők", text: "Küldtem ajánlatot, ránézel?", ts: DateTime.now().subtract(const Duration(hours: 2))),
      ],
    ),
    MockThread(
      id: "th3",
      peerName: "Fény Mester Bt.",
      messages: [
        MockMessage(id: "m1", threadId: "th3", from: "Én", text: "Köszönöm, elfogadtam.", ts: DateTime.now().subtract(const Duration(days: 1, hours: 3))),
      ],
    ),
  ];
}

String ft(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i=0;i<s.length;i++){
    final left = s.length - i;
    b.write(s[i]);
    if (left>1 && left%3==1) b.write(" ");
  }
  return "$b Ft";
}

String dt(BuildContext c, DateTime d) =>
  "${d.year}.${d.month.toString().padLeft(2,'0')}.${d.day.toString().padLeft(2,'0')} "
  "${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}";
