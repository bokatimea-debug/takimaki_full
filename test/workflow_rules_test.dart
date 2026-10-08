import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takimaki_full/services/workflow_store.dart';
import 'package:takimaki_full/services/profile_photo_sync.dart';
import 'package:takimaki_full/utils/work_schedule.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Map<String, dynamic> work(String id) => {
    'id': id,
    'request_id': id,
    'provider_id': 'peer',
    'customer_id': 'me',
    'status': 'Elfogadva',
    'date': '2026-01-01',
    'time': '10:00',
    'duration_minutes': 60,
  };
  setUp(
    () => SharedPreferences.setMockInitialValues({'registration_phone': 'me'}),
  );
  test('Only one ticket per order and reporter-target pair; append preserves ticket', () async {
    await WorkflowStore.report(work('one'), 'customer', 'Más', 'Leírás');
    await expectLater(
      WorkflowStore.report(work('one'), 'provider', 'Más', 'Második'),
      throwsStateError,
    );
    await expectLater(
      WorkflowStore.report(work('two'), 'customer', 'Más', 'Második'),
      throwsStateError,
    );
    await WorkflowStore.appendTicket('one', 'Kiegészítés');
    final tickets = await WorkflowStore.ownTickets('customer');
    expect(tickets, hasLength(1));
    expect(tickets.single['updates'], hasLength(1));
    expect(tickets.single['private'], isTrue);
  });
  test('Other account cannot view or append private ticket', () async {
    await WorkflowStore.report(work('one'), 'customer', 'Más', 'Leírás');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registration_phone', 'another');
    expect(await WorkflowStore.ownTickets('customer'), isEmpty);
    await WorkflowStore.appendTicket('one', 'Nem saját');
    final all = jsonDecode(prefs.getString('private_problem_tickets')!) as List;
    expect(all.single['updates'], isEmpty);
  });
  test(
    'Reviews are hidden until both arrive or exactly 72 hours after finish',
    () {
      final w = {
        ...work('one'),
        'customer_feedback': {'rating': 4},
      };
      expect(
        WorkSchedule.reviewsVisible(w, DateTime(2026, 1, 4, 10, 59)),
        isFalse,
      );
      expect(WorkSchedule.reviewsVisible(w, DateTime(2026, 1, 4, 11)), isTrue);
      expect(
        WorkSchedule.canReview(w, 'provider', DateTime(2026, 1, 4, 11)),
        isFalse,
      );
      w['provider_feedback'] = {'rating': 5};
      expect(WorkSchedule.reviewsVisible(w, DateTime(2026, 1, 1, 12)), isTrue);
    },
  );
  test('Rescheduling updates both roles, history and reminder times without confirmation', () async {
    final prefs = await SharedPreferences.getInstance();
    final w = work('one');
    for (final key in ['customer_orders', 'provider_orders']) {
      await prefs.setString(key, jsonEncode([w]));
    }
    final tomorrow = DateTime.now().add(const Duration(days: 2));
    await WorkflowStore.reschedule(
      w,
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14),
      90,
      'customer',
    );
    for (final key in ['customer_orders', 'provider_orders']) {
      final saved = (jsonDecode(prefs.getString(key)!) as List).single;
      expect(saved['time'], '14:00');
      expect(saved['duration_minutes'], 90);
      expect(saved['schedule_history'], hasLength(1));
    }
    final notices =
        jsonDecode(prefs.getString('workflow_notifications')!) as List;
    expect(notices.where((n) => n['scheduled'] == true), hasLength(3));
    expect(notices.last['role'], 'provider');
  });
  test('Cancelled work removes all scheduled reminders', () async {
    await WorkflowStore.reconcileReminders({
      ...work('one'),
      'date': DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String()
          .split('T')
          .first,
    });
    await WorkflowStore.reconcileReminders({
      ...work('one'),
      'status': 'Lemondva',
    });
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('workflow_notifications')!), isEmpty);
  });
  test(
    'Photo propagation updates matching identity and preserves other partner',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'customer_orders',
        jsonEncode([
          {'customer_id': 'me', 'customer_photo_b64': 'old'},
          {'customer_id': 'another', 'customer_photo_b64': 'other'},
        ]),
      );
      await ProfilePhotoSync.sync('new');
      final records = jsonDecode(prefs.getString('customer_orders')!) as List;
      expect(records.first['customer_photo_b64'], 'new');
      expect(records.last['customer_photo_b64'], 'other');
    },
  );
  test(
    'Hidden review does not affect public average until both reviews arrive',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final date = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .split('T')
          .first;
      final w = {
        ...work('one'),
        'date': date,
        'provider_feedback': {'rating': 4},
      };
      await prefs.setString('customer_orders', jsonEncode([w]));
      await WorkflowStore.refreshRatingSummary('customer');
      expect(prefs.getDouble('customer_rating'), 0);
      w['customer_feedback'] = {'rating': 5};
      await prefs.setString('customer_orders', jsonEncode([w]));
      await WorkflowStore.refreshRatingSummary('customer');
      expect(prefs.getDouble('customer_rating'), 4);
      expect(prefs.getInt('customer_rating_count'), 1);
    },
  );
  test(
    'Legacy accepted booking still blocks new offer with stable provider ID',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final old = {
        ...work('old'),
        'provider_id': null,
        'provider_name': 'Nagy Petra',
      };
      await prefs.setString('provider_orders', jsonEncode([old]));
      final candidate = {
        ...work('new'),
        'provider_id': 'stable-peer',
        'provider_name': 'Nagy Petra',
        'time': '10:30',
      };
      await expectLater(
        WorkflowStore.checkConflict(candidate),
        throwsStateError,
      );
    },
  );
}
