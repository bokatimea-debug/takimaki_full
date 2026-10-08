import '../lib/utils/work_schedule.dart';
void main() {
  Map<String, dynamic> work(String id, String time, int duration, {String address = 'A'}) => {
    'request_id': id, 'date': '2026-10-06', 'time': time,
    'duration_minutes': duration, 'address': address, 'status': 'Elfogadva'};
  void check(bool ok, String message) { if (!ok) throw StateError(message); }
  final booked = work('one', '10:00', 60);
  check(WorkSchedule.conflict(work('two', '10:30', 60), [booked]) != null, 'overlap');
  check(WorkSchedule.conflict(work('two', '11:15', 60, address: 'B'), [booked]) != null, 'travel buffer');
  check(WorkSchedule.conflict(work('two', '11:30', 60, address: 'B'), [booked]) == null, 'buffer boundary');
  check(WorkSchedule.conflict(work('two', '11:00', 60), [booked]) == null, 'same address');
  check(WorkSchedule.conflict(booked, [booked]) == null, 'exclude own booking');
  check(WorkSchedule.conflict(work('two', '10:30', 60), [{...booked, 'status': 'Lemondva'}]) == null, 'cancelled booking');
  check(WorkSchedule.conflict(work('two', '08:45', 60, address: 'B'), [booked]) != null, 'buffer before work');
  check(!WorkSchedule.canReview(booked, 'customer', DateTime(2026,10,6,10,59)), 'premature review');
  check(WorkSchedule.canReview(booked, 'customer', DateTime(2026,10,6,11)), 'review start');
  check(!WorkSchedule.canReview(booked, 'customer', DateTime(2026,10,9,11)), 'review deadline');
  check(!WorkSchedule.canReview({...booked, 'customer_feedback': {}}, 'customer', DateTime(2026,10,6,11)), 'duplicate review');
  check(!WorkSchedule.reviewsVisible({...booked, 'customer_feedback': {}}, DateTime(2026,10,7)), 'single hidden review');
  check(WorkSchedule.reviewsVisible({...booked, 'customer_feedback': {}, 'provider_feedback': {}}, DateTime(2026,10,7)), 'both visible');
  check(WorkSchedule.reviewsVisible({...booked, 'customer_feedback': {}}, DateTime(2026,10,9,11)), 'single review after deadline');
  print('14 scheduling and review rule checks passed.');
}
