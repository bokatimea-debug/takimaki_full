import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/work_schedule.dart';
import 'local_marketplace_store.dart';

class DeviceWorkflow {
  static const channel = MethodChannel('takimaki/device');
  static Future<bool> permission(String method) async {
    try {
      return await channel.invokeMethod<bool>(method) ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> calendars() async {
    final rows = await channel.invokeListMethod<dynamic>('calendars') ?? [];
    return rows.map((v) => Map<String, dynamic>.from(v as Map)).toList();
  }

  static Future<void> notify(
    String id,
    String role,
    String title,
    String body,
    DateTime at,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notify_push') ?? true)) return;
    try {
      await channel.invokeMethod('schedule', {
        'key': '$id:$role:${at.microsecondsSinceEpoch}',
        'id': id,
        'role': role,
        'title': title,
        'body': body,
        'at': at.millisecondsSinceEpoch,
      });
    } on MissingPluginException {
      /* Unsupported platform. */
    } on PlatformException catch (e) {
      await prefs.setString(
        'device_sync_error',
        e.message ?? 'Értesítési hiba',
      );
    }
  }

  static Future<void> syncWork(
    Map<String, dynamic> work,
    List<Map<String, dynamic>> reminders,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final id = WorkSchedule.id(work);
    try {
      await channel.invokeMethod('cancelWork', id);
      if (prefs.getBool('notify_push') ?? true) {
        if (reminders.isNotEmpty) await permission('notificationPermission');
        for (final reminder in reminders) {
          final at = DateTime.parse(reminder['at'].toString());
          await channel.invokeMethod('schedule', {
            'key': '$id:${reminder['role']}:${reminder['title']}',
            'id': id,
            'role': reminder['role'],
            'title': reminder['title'],
            'body': reminder['body'],
            'at': at.millisecondsSinceEpoch,
          });
        }
      }
      final calendar = prefs.getInt('phone_calendar_id');
      final from = WorkSchedule.start(work);
      final until = WorkSchedule.end(work);
      if (calendar != null && from != null && until != null) {
        await channel.invokeMethod('syncEvent', {
          'calendar': calendar,
          'id': id,
          'cancelled': work['status'] == 'Lemondva',
          'start': from.millisecondsSinceEpoch,
          'end': until.millisecondsSinceEpoch,
          'title': 'Takimaki • ${work['service'] ?? work['title']}',
          'address': work['address'] ?? '',
          'description':
              '${work['provider_first_name'] ?? work['customer_first_name'] ?? ''}\n${work['note'] ?? ''}',
        });
      }
      await prefs.remove('device_sync_error');
    } on MissingPluginException {
      // Flutter widget tests and unsupported platforms have no Android channel.
    } on PlatformException catch (e) {
      await prefs.setString(
        'device_sync_error',
        e.message ?? 'Naptár vagy értesítés szinkronizálási hiba.',
      );
    }
  }

  static Future<void> syncExisting() async {
    final works = {
      ...{
        for (final w in await LocalMarketplaceStore.customerOrders())
          WorkSchedule.id(w): w,
      },
      ...{
        for (final w in await LocalMarketplaceStore.providerOrders())
          WorkSchedule.id(w): w,
      },
    };
    for (final work in works.values) {
      if (!WorkSchedule.active(work) && work['status'] != 'Teljesítve')
        continue;
      // Calendar only; preserve notification schedules already stored by Android.
      final prefs = await SharedPreferences.getInstance();
      final calendar = prefs.getInt('phone_calendar_id');
      if (calendar == null) return;
      final from = WorkSchedule.start(work);
      final until = WorkSchedule.end(work);
      if (from == null || until == null) continue;
      await channel.invokeMethod('syncEvent', {
        'calendar': calendar,
        'id': WorkSchedule.id(work),
        'cancelled': false,
        'start': from.millisecondsSinceEpoch,
        'end': until.millisecondsSinceEpoch,
        'title': 'Takimaki • ${work['service'] ?? work['title']}',
        'address': work['address'] ?? '',
        'description': work['note'] ?? '',
      });
    }
  }
}
