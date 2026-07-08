import 'package:remind_me/models/contact_date_event.dart';

class ContactModel {
  const ContactModel({
    required this.id,
    required this.name,
    this.phone,
    this.events = const [],
  });

  final String id;
  final String name;
  final String? phone;
  final List<ContactDateEvent> events;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (phone != null) 'phone': phone,
        'events': events.map((event) => event.toJson()).toList(),
      };

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      events: (json['events'] as List<dynamic>? ?? [])
          .map((event) => ContactDateEvent.fromJson(
                Map<String, dynamic>.from(event as Map),
              ))
          .toList(),
    );
  }
}
