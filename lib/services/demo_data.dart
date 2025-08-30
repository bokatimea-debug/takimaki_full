// lib/services/demo_data.dart
class DemoOrders {
  static final customerOrders = <Map<String, String>>[
    {"title":"Általános takarítás","status":"Teljesítve","date":"2025.08.10"},
    {"title":"Villanyszerelés","status":"Folyamatban","date":"2025.08.28"},
    {"title":"Nagytakarítás","status":"Lemondva","date":"2025.08.05"},
  ];

  static final providerOrders = <Map<String, String>>[
    {"title":"Takarítás – V. ker.","status":"Teljesítve","date":"2025.08.12"},
    {"title":"Villany – XIII. ker.","status":"Folyamatban","date":"2025.08.27"},
    {"title":"Karbantartás – XI. ker.","status":"Függőben","date":"2025.08.30"},
  ];
}

class DemoMessages {
  static final threads = <Map<String, String>>[
    {"name":"Kiss Anna","last":"Köszönöm, várom holnap 9-kor!","time":"13:20"},
    {"name":"Tiszta Otthon Bt.","last":"Árajánlat: 12 000 Ft/óra","time":"12:05"},
    {"name":"VillámSzerelő","last":"Szerdán 10-kor jó?","time":"Tegnap"},
  ];
}

class DemoRequests {
  static final incoming = <Map<String, String>>[
    {"customer":"Kiss Anna","service":"Általános takarítás","when":"2025.09.05 • 09:00","address":"Budapest, Lázár u. 1."},
    {"customer":"Nagy Péter","service":"Villanyszerelés","when":"2025.09.06 • 14:00","address":"Budapest, Váci út 10."},
  ];
}
