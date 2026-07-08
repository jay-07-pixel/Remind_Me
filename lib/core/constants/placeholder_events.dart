import 'package:remind_me/models/contact_event.dart';
import 'package:remind_me/models/event_type.dart';

abstract final class PlaceholderEvents {
  static List<ContactEvent> get todayEvents => [
        ContactEvent(
          contactId: '1',
          contactName: 'Priya Sharma',
          eventType: EventType.birthday,
          date: DateTime.now(),
        ),
        ContactEvent(
          contactId: '2',
          contactName: 'Rahul & Meera',
          eventType: EventType.anniversary,
          date: DateTime.now(),
        ),
        ContactEvent(
          contactId: '3',
          contactName: 'Amit Patel',
          eventType: EventType.birthday,
          date: DateTime.now(),
        ),
      ];

  static List<ContactEvent> get upcomingEvents => [
        ContactEvent(
          contactId: '4',
          contactName: 'Neha Gupta',
          eventType: EventType.birthday,
          date: DateTime.now().add(const Duration(days: 3)),
        ),
        ContactEvent(
          contactId: '5',
          contactName: 'Vikram Singh',
          eventType: EventType.anniversary,
          date: DateTime.now().add(const Duration(days: 5)),
        ),
        ContactEvent(
          contactId: '6',
          contactName: 'Ananya Reddy',
          eventType: EventType.birthday,
          date: DateTime.now().add(const Duration(days: 8)),
        ),
        ContactEvent(
          contactId: '7',
          contactName: 'Karan Mehta',
          eventType: EventType.birthday,
          date: DateTime.now().add(const Duration(days: 12)),
        ),
      ];
}
