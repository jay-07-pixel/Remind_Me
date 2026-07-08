import 'package:remind_me/models/contact_date_event.dart';

abstract final class DateEventUtils {
  static bool isToday(ContactDateEvent event, DateTime reference) {
    return event.month == reference.month && event.day == reference.day;
  }

  static DateTime nextOccurrence(ContactDateEvent event, DateTime reference) {
    final today = DateTime(reference.year, reference.month, reference.day);
    var candidate = DateTime(reference.year, event.month, event.day);

    if (!candidate.isBefore(today)) {
      return candidate;
    }

    return DateTime(reference.year + 1, event.month, event.day);
  }

  static bool isUpcoming(
    ContactDateEvent event,
    DateTime reference, {
    int withinDays = 30,
  }) {
    if (isToday(event, reference)) return false;

    final next = nextOccurrence(event, reference);
    final limit = today(reference).add(Duration(days: withinDays));
    return !next.isAfter(limit);
  }

  static DateTime today(DateTime reference) {
    return DateTime(reference.year, reference.month, reference.day);
  }
}
