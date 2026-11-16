import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const rooms = <String, List<String>>{
  'Fürdőszoba': ['Szennyes összegyűjtése','WC tisztítása','Mosdó és zuhany tisztítása','Tükrök tisztítása','Vízkő és hajszálak eltávolítása','Szemetes ürítése','Padló felmosása','Bekészítések pótlása','Tiszta törölközők kihelyezése'],
  'Hálószoba': ['Szellőztetés','Ágynemű leszedése','Matrac ellenőrzése','Tiszta ágynemű felhúzása','Felületek portalanítása','Szekrény átnézése','Padló tisztítása','Ágy és szoba ellenőrzése'],
  'Konyha': ['Edények elmosása','Munkapult tisztítása','Mosogató tisztítása','Főzőlap tisztítása','Mikrohullámú sütő tisztítása','Hűtő átnézése','Szemetes ürítése','Padló tisztítása','Bekészítések pótlása'],
  'Nappali és előszoba': ['Szellőztetés','Bútorok portalanítása','Kanapé tisztítása','Párnák elrendezése','Kapcsolók és kilincsek tisztítása','Tükrök tisztítása','Padló tisztítása','Tárgyak visszahelyezése'],
  'Végső ellenőrzés': ['Ablakok ellenőrzése','Világítás ellenőrzése','Hőmérséklet ellenőrzése','Talált tárgyak ellenőrzése','Hiányosságok feljegyzése','Kulcsok ellenőrzése','Vendégtájékoztató kihelyezése','Ajtó és zár ellenőrzése'],
};

class CleaningChecklist {
  static String _key(String address) =>
      'cleaning_template_${address.trim().toLowerCase()}';

  static List<Map<String, dynamic>> defaults() => [
    for (final room in rooms.entries)
      for (var index = 0; index < room.value.length; index++)
        {
          'room': room.key,
          'label': room.value[index],
          'photoRequired': index == room.value.length - 1,
        },
  ];

  static Future<List<Map<String, dynamic>>> template(String address) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(address));
    return raw == null ? defaults() : tasks(jsonDecode(raw));
  }

  static List<Map<String, dynamic>> tasks(Object? data) => [
    if (data is List)
      for (final entry in data)
        if (entry is Map) Map<String, dynamic>.from(entry),
  ];

  static Future<void> saveTemplate(String address, List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_key(address), jsonEncode(list))) {
      throw StateError('A checklist mentése nem sikerült.');
    }
  }

  static bool canComplete(List<Map<String, dynamic>> list) =>
      list.every((task) => task['done'] == true &&
        (task['photoRequired'] != true ||
          (task['photo'] is String && (task['photo'] as String).isNotEmpty)));
}
