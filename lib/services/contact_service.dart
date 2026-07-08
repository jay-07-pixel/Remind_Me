import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:remind_me/core/utils/date_event_utils.dart';
import 'package:remind_me/models/contact_date_event.dart';
import 'package:remind_me/models/contact_event.dart';
import 'package:remind_me/models/contact_model.dart';
import 'package:remind_me/models/event_type.dart';
import 'package:remind_me/services/permission_service.dart';
import 'package:remind_me/services/storage_service.dart';

class ContactService {
  ContactService._();

  static final ContactService instance = ContactService._();

  final _storage = StorageService.instance;
  final _permissionService = PermissionService.instance;

  Future<List<ContactModel>> syncContacts({
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.1);

    final hasPermission = await _permissionService.isContactsGranted();
    if (!hasPermission) {
      throw ContactSyncException('Contacts permission is not granted.');
    }

    onProgress?.call(0.25);

    final deviceContacts = await FlutterContacts.getAll(
      properties: {
        ContactProperty.name,
        ContactProperty.phone,
        ContactProperty.event,
      },
    );

    onProgress?.call(0.65);

    final contacts = deviceContacts
        .map(_mapContact)
        .where((contact) => contact.name.trim().isNotEmpty)
        .toList();

    onProgress?.call(0.85);

    await _storage.saveContacts(contacts);
    await _storage.setContactsSynced(true);

    onProgress?.call(1);

    return contacts;
  }

  Future<List<ContactModel>> getStoredContacts() {
    return _storage.getContacts();
  }

  Future<ContactModel?> getContactById(String contactId) async {
    final contacts = await getStoredContacts();
    for (final contact in contacts) {
      if (contact.id == contactId) {
        return contact;
      }
    }
    return null;
  }

  Future<bool> isContactsSynced() {
    return _storage.isContactsSynced();
  }

  Future<List<ContactEvent>> getTodayEvents() async {
    final contacts = await getStoredContacts();
    return _buildEvents(
      contacts: contacts,
      reference: DateTime.now(),
      includeToday: true,
      includeUpcoming: false,
    );
  }

  Future<List<ContactEvent>> getUpcomingEvents({int withinDays = 30}) async {
    final contacts = await getStoredContacts();
    return _buildEvents(
      contacts: contacts,
      reference: DateTime.now(),
      includeToday: false,
      includeUpcoming: true,
      withinDays: withinDays,
    );
  }

  Future<List<ContactEvent>> getAllEvents() async {
    final contacts = await getStoredContacts();
    return _buildAllEvents(
      contacts: contacts,
      reference: DateTime.now(),
    );
  }

  List<ContactEvent> _buildEvents({
    required List<ContactModel> contacts,
    required DateTime reference,
    required bool includeToday,
    required bool includeUpcoming,
    int withinDays = 30,
  }) {
    final events = <ContactEvent>[];

    for (final contact in contacts) {
      for (final event in contact.events) {
        final isToday = DateEventUtils.isToday(event, reference);
        final isUpcoming =
            DateEventUtils.isUpcoming(event, reference, withinDays: withinDays);

        if ((includeToday && isToday) || (includeUpcoming && isUpcoming)) {
          events.add(
            ContactEvent(
              contactId: contact.id,
              contactName: contact.name,
              eventType: event.eventType,
              date: DateEventUtils.nextOccurrence(event, reference),
              customLabel: event.customLabel,
            ),
          );
        }
      }
    }

    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  List<ContactEvent> _buildAllEvents({
    required List<ContactModel> contacts,
    required DateTime reference,
  }) {
    final events = <ContactEvent>[];

    for (final contact in contacts) {
      for (final event in contact.events) {
        events.add(
          ContactEvent(
            contactId: contact.id,
            contactName: contact.name,
            eventType: event.eventType,
            date: DateEventUtils.nextOccurrence(event, reference),
            customLabel: event.customLabel,
          ),
        );
      }
    }

    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  ContactModel _mapContact(Contact contact) {
    return ContactModel(
      id: contact.id ?? contact.hashCode.toString(),
      name: _resolveName(contact),
      phone: _resolvePhone(contact),
      events: contact.events.map(_mapEvent).toList(),
    );
  }

  String _resolveName(Contact contact) {
    final displayName = contact.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final name = contact.name;
    if (name != null) {
      final parts = [
        name.first,
        name.middle,
        name.last,
      ].whereType<String>().map((part) => part.trim()).where((part) => part.isNotEmpty);

      final resolved = parts.join(' ');
      if (resolved.isNotEmpty) return resolved;
    }

    return 'Unknown';
  }

  String? _resolvePhone(Contact contact) {
    if (contact.phones.isEmpty) return null;

    for (final phone in contact.phones) {
      if (phone.isPrimary == true) {
        return phone.number;
      }
    }

    return contact.phones.first.number;
  }

  ContactDateEvent _mapEvent(Event event) {
    return ContactDateEvent(
      eventType: _mapEventType(event),
      month: event.month,
      day: event.day,
      year: event.year,
      customLabel: event.label.customLabel,
    );
  }

  EventType _mapEventType(Event event) {
    return switch (event.label.label) {
      EventLabel.birthday => EventType.birthday,
      EventLabel.anniversary => EventType.anniversary,
      EventLabel.other || EventLabel.custom => EventType.other,
    };
  }
}

class ContactSyncException implements Exception {
  ContactSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}
