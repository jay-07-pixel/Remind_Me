import 'package:remind_me/models/event_type.dart';

class ContactDateEvent {
  const ContactDateEvent({
    required this.eventType,
    required this.month,
    required this.day,
    this.year,
    this.customLabel,
  });

  final EventType eventType;
  final int month;
  final int day;
  final int? year;
  final String? customLabel;

  Map<String, dynamic> toJson() => {
        'eventType': eventType.name,
        'month': month,
        'day': day,
        if (year != null) 'year': year,
        if (customLabel != null) 'customLabel': customLabel,
      };

  factory ContactDateEvent.fromJson(Map<String, dynamic> json) {
    return ContactDateEvent(
      eventType: EventType.values.byName(json['eventType'] as String),
      month: json['month'] as int,
      day: json['day'] as int,
      year: json['year'] as int?,
      customLabel: json['customLabel'] as String?,
    );
  }
}
