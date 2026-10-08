import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/work_schedule.dart';
import 'local_marketplace_store.dart';
import 'device_workflow.dart';

/// Local test implementation. Remote delivery/AI requires a backend.
class WorkflowStore {
  static Future<List<Map<String, dynamic>>> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> _write(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<void> update(
    String requestId,
    Map<String, dynamic> values,
  ) async {
    for (final key in [
      LocalMarketplaceStore.customerOrdersKey,
      LocalMarketplaceStore.providerOrdersKey,
      LocalMarketplaceStore.requestsKey,
    ]) {
      final data = await _read(key);
      for (final work in data) {
        if (WorkSchedule.id(work) == requestId) work.addAll(values);
      }
      await _write(key, data);
    }
  }

  static Future<void> reschedule(
    Map<String, dynamic> work,
    DateTime when,
    int durationMinutes,
    String role,
  ) async {
    if (!WorkSchedule.active(work))
      throw StateError('Csak elfogadott munka módosítható.');
    if (!when.isAfter(DateTime.now()) || durationMinutes <= 0) {
      throw StateError('Jövőbeli időpont és pozitív időtartam szükséges.');
    }
    final changes = <String, dynamic>{
      'date':
          '${when.year}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}',
      'time':
          '${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}',
      'duration_minutes': durationMinutes,
    };
    await checkConflict({...work, ...changes});
    final history = List<dynamic>.from(work['schedule_history'] as List? ?? []);
    history.add({
      'at': DateTime.now().toIso8601String(),
      'role': role,
      'old_date': work['date'],
      'old_time': work['time'],
      'old_duration_minutes': WorkSchedule.minutes(work),
      ...changes,
    });
    await update(WorkSchedule.id(work), {
      ...changes,
      'schedule_history': history,
    });
    final fresh = (await LocalMarketplaceStore.customerOrders())
        .where((w) => WorkSchedule.id(w) == WorkSchedule.id(work))
        .firstOrNull;
    if (fresh != null) await reconcileReminders(fresh);
    await enqueue(
      WorkSchedule.id(work),
      role == 'provider' ? 'customer' : 'provider',
      'Időpont megváltozott',
      '${work['date']} ${work['time']} → ${changes['date']} ${changes['time']}',
    );
  }

  static Future<void> checkConflict(Map<String, dynamic> candidate) async {
    final prefs = await SharedPreferences.getInstance();
    final buffer = prefs.getInt('travel_buffer_minutes') ?? 30;
    final providerId = candidate['provider_id']?.toString();
    final providerName = (candidate['provider_name'] ?? candidate['provider'])
        ?.toString();
    final booked = (await LocalMarketplaceStore.providerOrders()).where((work) {
      final savedId = work['provider_id']?.toString();
      if (providerId != null && savedId != null) return providerId == savedId;
      final savedName = (work['provider_name'] ?? work['provider'])?.toString();
      return providerName != null &&
          providerName.trim().isNotEmpty &&
          savedName == providerName;
    });
    final found = WorkSchedule.conflict(
      candidate,
      booked,
      bufferMinutes: buffer,
    );
    if (found != null)
      throw StateError(
        'Ütköző vagy túl szoros időpont: ${found['date']} ${found['time']}. Legalább $buffer perc szünet szükséges különböző címek között.',
      );
  }

  static Future<void> feedback(
    Map<String, dynamic> work,
    String role,
    bool fulfilled,
    int rating,
    String review,
  ) async {
    final current = (await LocalMarketplaceStore.customerOrders())
        .where((e) => WorkSchedule.id(e) == WorkSchedule.id(work))
        .firstOrNull;
    if (current == null ||
        !WorkSchedule.canReview(current, role, DateTime.now())) {
      throw StateError('Már értékeltél, vagy a 3 napos határidő lejárt.');
    }
    if (rating < 1 || rating > 5) throw StateError('1–5 csillag adható.');
    await update(WorkSchedule.id(work), {
      '${role}_feedback': {
        'fulfilled': fulfilled,
        'rating': rating,
        'review': review.trim(),
        'submitted_at': DateTime.now().toIso8601String(),
      },
    });
  }

  static Future<void> refreshRatingSummary(String role) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('registration_phone');
    final fullName = [
      prefs.getString('${role}_last_name') ??
          prefs.getString('customer_last_name') ??
          '',
      prefs.getString('${role}_first_name') ??
          prefs.getString('customer_first_name') ??
          '',
    ].where((s) => s.isNotEmpty).join(' ');
    final peer = role == 'customer' ? 'provider' : 'customer';
    final works = await _read(
      role == 'customer'
          ? LocalMarketplaceStore.customerOrdersKey
          : LocalMarketplaceStore.providerOrdersKey,
    );
    final ownWorks = works
        .where(
          (w) =>
              (phone != null && w['${role}_id'] == phone) ||
              (w['${role}_id'] == null &&
                  fullName.isNotEmpty &&
                  (w['${role}_name'] ?? w[role]) == fullName),
        )
        .toList();
    if (!ownWorks.any((w) => w['${peer}_feedback'] is Map)) return;
    final ratings = <num>[];
    for (final w in ownWorks) {
      if (w['${peer}_feedback'] is Map &&
          WorkSchedule.reviewsVisible(w, DateTime.now())) {
        final rating = w['${peer}_feedback']['rating'];
        if (rating is num) ratings.add(rating);
      } else if (role == 'provider' && w['rating'] is num) {
        ratings.add(w['rating'] as num);
      }
    }
    await prefs.setDouble(
      '${role}_rating',
      ratings.isEmpty ? 0 : ratings.reduce((a, b) => a + b) / ratings.length,
    );
    await prefs.setInt('${role}_rating_count', ratings.length);
  }

  static Future<void> report(
    Map<String, dynamic> work,
    String role,
    String reason,
    String text,
  ) async {
    if (text.trim().isEmpty) throw StateError('Írd le röviden a problémát.');
    final prefs = await SharedPreferences.getInstance();
    final reporter = prefs.getString('registration_phone') ?? 'local-account';
    final peerRole = role == 'customer' ? 'provider' : 'customer';
    final target =
        work['${peerRole}_id'] ??
        work['${peerRole}_phone'] ??
        work['${peerRole}_name'] ??
        work[peerRole];
    if (target == null || target.toString().trim().isEmpty) {
      throw StateError('Ehhez a munkához még nincs partner.');
    }
    final tickets = await _read('private_problem_tickets');
    if (tickets.any((t) => t['request_id'] == WorkSchedule.id(work))) {
      throw StateError('Ehhez a megrendeléshez már van hibajegy.');
    }
    if (tickets.any(
      (t) => t['reporter'] == reporter && t['target'] == target.toString(),
    )) {
      throw StateError(
        'Ezt a partnert már jelentetted. A meglévő hibajegyhez adhatsz információt.',
      );
    }
    tickets.add({
      'request_id': WorkSchedule.id(work),
      'reporter': reporter,
      'target': target.toString(),
      'role': role,
      'reason': reason,
      'description': text.trim(),
      'status': 'Beérkezett',
      'ai_status': 'Szerveres feldolgozásra vár',
      'private': true,
      'created_at': DateTime.now().toIso8601String(),
      'updates': [],
    });
    await _write('private_problem_tickets', tickets);
  }

  static Future<List<Map<String, dynamic>>> ownTickets(String role) async {
    final prefs = await SharedPreferences.getInstance();
    final reporter = prefs.getString('registration_phone') ?? 'local-account';
    return (await _read('private_problem_tickets'))
        .where((t) => t['role'] == role && t['reporter'] == reporter)
        .toList();
  }

  static Future<void> appendTicket(String id, String text) async {
    if (text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final reporter = prefs.getString('registration_phone') ?? 'local-account';
    final tickets = await _read('private_problem_tickets');
    for (final ticket in tickets.where(
      (t) => t['request_id'] == id && t['reporter'] == reporter,
    )) {
      final updates = List<dynamic>.from(ticket['updates'] as List? ?? []);
      updates.add({
        'text': text.trim(),
        'at': DateTime.now().toIso8601String(),
      });
      ticket['updates'] = updates;
    }
    await _write('private_problem_tickets', tickets);
  }

  static Future<void> enqueue(
    String id,
    String role,
    String title,
    String body, {
    DateTime? at,
  }) async {
    final data = await _read('workflow_notifications');
    data.add({
      'request_id': id,
      'role': role,
      'title': title,
      'body': body,
      'at': (at ?? DateTime.now()).toIso8601String(),
      'read': false,
    });
    await _write('workflow_notifications', data);
    unawaited(
      DeviceWorkflow.notify(
        id,
        role,
        title,
        body,
        at ?? DateTime.now().add(const Duration(seconds: 2)),
      ),
    );
  }

  static Future<List<Map<String, dynamic>>> visibleNotifications(
    String role,
  ) async {
    final now = DateTime.now();
    final data = await _read('workflow_notifications');
    return data
        .where(
          (notice) =>
              notice['role'] == role &&
              !(DateTime.tryParse(notice['at']?.toString() ?? '')
                      ?.isAfter(now) ??
                  true),
        )
        .toList();
  }

  static Future<int> unreadNotificationCount(String role) async =>
      (await visibleNotifications(role))
          .where((notice) => notice['read'] != true)
          .length;

  static Future<int> unreadAcceptedWorkCount(String role) async =>
      (await visibleNotifications(role))
          .where(
            (notice) =>
                notice['read'] != true &&
                notice['title'] == 'Új elfogadott munka',
          )
          .length;

  static Future<int> unreadCountByTitle(String role, String title) async =>
      (await visibleNotifications(role))
          .where(
            (notice) => notice['read'] != true && notice['title'] == title,
          )
          .length;

  static Future<void> markNotificationRead(
    String role,
    Map<String, dynamic> notice,
  ) async {
    final data = await _read('workflow_notifications');
    for (final item in data) {
      if (item['role'] == role &&
          item['request_id'] == notice['request_id'] &&
          item['title'] == notice['title'] &&
          item['at'] == notice['at']) {
        item['read'] = true;
      }
    }
    await _write('workflow_notifications', data);
  }

  static Future<void> markNotificationsReadByTitle(
    String role,
    String title,
  ) async {
    final data = await _read('workflow_notifications');
    for (final item in data) {
      if (item['role'] == role && item['title'] == title) item['read'] = true;
    }
    await _write('workflow_notifications', data);
  }

  static Future<void> reconcileReminders(Map<String, dynamic> work) async {
    final id = WorkSchedule.id(work);
    final notifications = await _read('workflow_notifications');
    notifications.removeWhere(
      (n) => n['request_id'] == id && n['scheduled'] == true,
    );
    final from = WorkSchedule.start(work);
    final until = WorkSchedule.end(work);
    if ((WorkSchedule.active(work) || work['status'] == 'Teljesítve') &&
        from != null &&
        until != null) {
      if (WorkSchedule.active(work) && from.isAfter(DateTime.now())) {
        notifications.add({
          'request_id': id,
          'role': 'provider',
          'scheduled': true,
          'title': 'Közelgő munka',
          'body': '${work['service']} • ${work['address']} • ${work['time']}',
          'at':
              (from.subtract(const Duration(hours: 2)).isBefore(DateTime.now())
                      ? DateTime.now().add(const Duration(seconds: 5))
                      : from.subtract(const Duration(hours: 2)))
                  .toIso8601String(),
          'read': false,
        });
      }
      for (final role in ['provider', 'customer']) {
        if (!until.isAfter(DateTime.now())) continue;
        notifications.add({
          'request_id': id,
          'role': role,
          'scheduled': true,
          'title': 'Teljesült a munka?',
          'body': 'Jelezd a teljesítést, értékeld a partnered vagy jelents problémát. Értékelési határidő: 3 nap.',
          'at': until.toIso8601String(),
          'read': false,
        });
      }
    }
    await _write('workflow_notifications', notifications);
    await DeviceWorkflow.syncWork(
      work,
      notifications
          .where((n) => n['request_id'] == id && n['scheduled'] == true)
          .toList(),
    );
  }
}
