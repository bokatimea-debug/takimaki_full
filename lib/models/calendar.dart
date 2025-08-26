// lib/models/calendar.dart
class ProviderCalendar {
  static final ProviderCalendar instance = ProviderCalendar._();
  ProviderCalendar._();

  // Egyszerű foglaláslista: (start, minutes, note)
  final List<_Booking> _bookings = [];

  bool isFree(DateTime start, int minutes) {
    final end = start.add(Duration(minutes: minutes));
    for (final b in _bookings) {
      final bEnd = b.start.add(Duration(minutes: b.minutes));
      final overlap = start.isBefore(bEnd) && end.isAfter(b.start);
      if (overlap) return false;
    }
    return true;
  }

  void book(DateTime start, int minutes, String note) {
    _bookings.add(_Booking(start, minutes, note));
  }

  List<_Booking> get all => List.unmodifiable(_bookings);
}

class _Booking {
  final DateTime start;
  final int minutes;
  final String note;
  _Booking(this.start, this.minutes, this.note);
}
