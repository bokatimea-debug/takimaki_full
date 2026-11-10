import 'dart:convert';
import 'dart:io';

enum RentalSource {
  airbnb('Airbnb'),
  booking('Booking.com');

  const RentalSource(this.label);
  final String label;

  Uri validate(String link) {
    final uri = Uri.tryParse(link.trim());
    if (uri == null) throw const FormatException('Hibás naptárlink.');
    final validHost = switch (this) {
      RentalSource.airbnb => const {
        'www.airbnb.com',
        'airbnb.com',
        'www.airbnb.hu',
        'www.airbnb.co.uk',
        'www.airbnb.de',
      }.contains(uri.host),
      RentalSource.booking => uri.host == 'admin.booking.com',
    };
    if (!validHost ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.port != 443 ||
        uri.hasFragment ||
        !uri.path.contains('ical') ||
        !(uri.path.endsWith('.ics') ||
            (this == RentalSource.booking &&
                uri.path.endsWith('/ical.html')))) {
      throw const FormatException(
        'Másold be a szálláshely HTTPS naptárexport-linkjét.',
      );
    }
    return uri;
  }
}

class RentalStay {
  const RentalStay(this.arrival, this.checkout, {required this.verified});
  final DateTime arrival;
  final DateTime checkout;

  /// Whether the export explicitly identifies this event as a reservation.
  final bool verified;
}

DateTime? _date(String? input) {
  if (input == null || !RegExp(r'^\d{8}$').hasMatch(input)) return null;
  final y = int.parse(input.substring(0, 4));
  final m = int.parse(input.substring(4, 6));
  final d = int.parse(input.substring(6, 8));
  final date = DateTime(y, m, d);
  return date.year == y && date.month == m && date.day == d ? date : null;
}

/// These rental exports use all-day dates. Ignore timed/recurring events;
/// their end timestamp is not a dependable checkout day.
List<RentalStay> parseRentalCalendar(String text, RentalSource source) {
  final lines = text
      .replaceFirst('\uFEFF', '')
      .replaceAll(RegExp(r'\r?\n[ \t]'), '')
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trimRight())
      .where((line) => line.isNotEmpty)
      .toList();
  if (lines.length < 2 ||
      lines.first != 'BEGIN:VCALENDAR' ||
      lines.last != 'END:VCALENDAR') {
    throw const FormatException(
      'A link nem olvasható iCal naptárat ad vissza.',
    );
  }
  final result = <RentalStay>[];
  Map<String, String>? event;
  var nested = 0;
  for (final line in lines.skip(1).take(lines.length - 2)) {
    if (line == 'BEGIN:VEVENT') {
      if (event != null) throw const FormatException('Hibás naptáresemény.');
      event = {};
      continue;
    }
    final fields = event;
    if (fields == null) continue;
    if (line == 'END:VEVENT' && nested == 0) {
      event = null;
      final status = fields['STATUS']?.toUpperCase();
      if (status == 'CANCELLED' ||
          status == 'TENTATIVE' ||
          fields.containsKey('RRULE') ||
          fields.containsKey('RECURRENCE-ID')) {
        continue;
      }
      final start = _date(fields['DTSTART']);
      final end = _date(fields['DTEND']);
      if (start == null || end == null || !end.isAfter(start)) continue;
      final summary = (fields['SUMMARY'] ?? '').trim().toLowerCase();
      final confirmed =
          summary == 'reserved' ||
          summary == 'reservation' ||
          summary == 'confirmed reservation';
      // Airbnb explicitly labels reservations. Booking exports may label
      // dates CLOSED without establishing whether a guest is checking out.
      if (confirmed ||
          (source == RentalSource.booking && summary == 'closed')) {
        result.add(RentalStay(start, end, verified: confirmed));
      }
      continue;
    }
    if (line.startsWith('BEGIN:')) {
      nested++;
    } else if (line.startsWith('END:') && nested > 0) {
      nested--;
    } else if (nested == 0) {
      final colon = line.indexOf(':');
      if (colon > 0)
        fields[line.substring(0, colon).split(';').first.toUpperCase()] = line
            .substring(colon + 1)
            .trim();
    }
  }
  if (event != null) throw const FormatException('Hiányos naptáresemény.');
  return result;
}

Future<List<RentalStay>> fetchRentalCalendar(
  RentalSource source,
  String link,
) async {
  final uri = source.validate(link);
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    return await (() async {
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      final response = await request.close();
      if (response.statusCode != 200) {
        throw const FormatException(
          'A naptár nem érhető el. Ellenőrizd az exportlinket.',
        );
      }
      final bytes = <int>[];
      await for (final chunk in response) {
        if (bytes.length + chunk.length > 2 * 1024 * 1024) {
          throw const FormatException('A naptárfájl túl nagy.');
        }
        bytes.addAll(chunk);
      }
      return parseRentalCalendar(utf8.decode(bytes), source);
    })().timeout(const Duration(seconds: 20));
  } finally {
    client.close(force: true);
  }
}

class RentalCleaningDraft {
  const RentalCleaningDraft(this.address, this.checkout);
  final String address;
  final DateTime checkout;
}
