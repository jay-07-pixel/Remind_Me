import 'package:remind_me/models/event_type.dart';

class ContactEvent {
  const ContactEvent({
    required this.contactId,
    required this.contactName,
    required this.eventType,
    required this.date,
    this.customLabel,
  });

  final String contactId;
  final String contactName;
  final EventType eventType;
  final DateTime date;
  final String? customLabel;

  String get eventLabel => eventType.displayLabel(customLabel: customLabel);

  String get initials {
    final parts = contactName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
