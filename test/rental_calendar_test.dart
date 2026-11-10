import 'package:flutter_test/flutter_test.dart';
import 'package:takimaki_full/services/rental_calendar.dart';

String calendar(List<String> events) =>
    ['BEGIN:VCALENDAR', 'VERSION:2.0', ...events, 'END:VCALENDAR'].join('\r\n');

String event(String summary, {String end = '20261203', String? status}) => [
  'BEGIN:VEVENT',
  'DTSTART;VALUE=DATE:20261201',
  'DTEND;VALUE=DATE:$end',
  'SUMMARY:$summary',
  if (status != null) 'STATUS:$status',
  'END:VEVENT',
].join('\r\n');

void main() {
  test('Airbnb distinguishes reservations from closures and cancellations', () {
    final stays = parseRentalCalendar(
      calendar([
        event('Reser\r\n ved'),
        event('Airbnb (Not available)'),
        event('Reserved', status: 'CANCELLED'),
      ]),
      RentalSource.airbnb,
    );
    expect(stays.single.checkout, DateTime(2026, 12, 3));
    expect(stays.single.verified, isTrue);
  });

  test('Booking closed dates require manual confirmation', () {
    final stays = parseRentalCalendar(
      calendar([event('CLOSED'), event('Reserved', end: '20261206')]),
      RentalSource.booking,
    );
    expect(stays.map((s) => s.verified), [false, true]);
  });

  test('Invalid, zero-length and timed dates cannot become drafts', () {
    final stays = parseRentalCalendar(
      calendar([
        event('Reserved', end: '20260230'),
        event('Reserved', end: '20261201'),
        event('Reserved', end: '20261203T100000Z'),
      ]),
      RentalSource.airbnb,
    );
    expect(stays, isEmpty);
  });

  test('Rejects incomplete downloads rather than treating them as empty', () {
    expect(
      () => parseRentalCalendar(
        'BEGIN:VCALENDAR\nBEGIN:VEVENT\nEND:VCALENDAR',
        RentalSource.airbnb,
      ),
      throwsFormatException,
    );
  });

  test('Only approved calendar hosts over HTTPS are accepted', () {
    const path = '/calendar/ical/123.ics?s=secret';
    expect(
      RentalSource.airbnb.validate('https://www.airbnb.com$path').host,
      'www.airbnb.com',
    );
    expect(
      RentalSource.booking
          .validate(
            'https://admin.booking.com/hotel/hoteladmin/ical.html?t=secret',
          )
          .host,
      'admin.booking.com',
    );
    expect(
      RentalSource.booking
          .validate('https://ical.booking.com/v1/export?t=secret')
          .host,
      'ical.booking.com',
    );
    for (final url in [
      'https://www.airbnb.com.evil.example$path',
      'http://www.airbnb.com$path',
      'https://www.airbnb.com:444$path',
      'https://user@www.airbnb.com$path',
    ]) {
      expect(() => RentalSource.airbnb.validate(url), throwsFormatException);
    }
  });
}
