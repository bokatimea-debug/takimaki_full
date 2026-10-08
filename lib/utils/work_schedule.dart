/// Scheduling and review rules shared by both roles. No device dependencies.
class WorkSchedule {
  static String id(Map<String, dynamic> work) =>
      (work['request_id'] ?? work['id'] ?? '').toString();
  static DateTime? start(Map<String, dynamic> work) =>
      DateTime.tryParse('${work['date'] ?? ''}T${work['time'] ?? ''}:00');
  static int minutes(Map<String, dynamic> work) =>
      (work['duration_minutes'] as num?)?.toInt() ?? 60;
  static DateTime? end(Map<String, dynamic> work) =>
      start(work)?.add(Duration(minutes: minutes(work)));
  static bool active(Map<String, dynamic> work) =>
      const ['Elfogadva', 'Folyamatban'].contains(work['status']);
  static DateTime? reviewDeadline(Map<String, dynamic> work) =>
      end(work)?.add(const Duration(days: 3));
  static bool canReview(Map<String, dynamic> work, String role, DateTime now) {
    final finish = end(work);
    final deadline = reviewDeadline(work);
    return work['status'] != 'Lemondva' &&
        finish != null &&
        deadline != null &&
        !now.isBefore(finish) &&
        now.isBefore(deadline) &&
        work['${role}_feedback'] == null &&
        const [
          'Elfogadva',
          'Folyamatban',
          'Teljesítve',
        ].contains(work['status']);
  }

  static bool reviewsVisible(Map<String, dynamic> work, DateTime now) =>
      (work['customer_feedback'] != null &&
          work['provider_feedback'] != null) ||
      (reviewDeadline(work) != null && !now.isBefore(reviewDeadline(work)!));
  static Map<String, dynamic>? conflict(
    Map<String, dynamic> candidate,
    Iterable<Map<String, dynamic>> booked, {
    int bufferMinutes = 30,
  }) {
    final from = start(candidate);
    final until = end(candidate);
    if (from == null || until == null || !until.isAfter(from)) {
      throw StateError('Érvényes időpont és időtartam szükséges.');
    }
    for (final work in booked) {
      if (!active(work) || id(work) == id(candidate)) continue;
      final otherFrom = start(work);
      final otherUntil = end(work);
      if (otherFrom == null || otherUntil == null) continue;
      final sameAddress =
          (work['address'] ?? '').toString().trim().toLowerCase() ==
          (candidate['address'] ?? '').toString().trim().toLowerCase();
      final gap = Duration(minutes: sameAddress ? 0 : bufferMinutes);
      if (from.isBefore(otherUntil.add(gap)) &&
          until.add(gap).isAfter(otherFrom))
        return work;
    }
    return null;
  }
}
