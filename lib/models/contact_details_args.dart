import 'package:remind_me/models/contact_event.dart';
import 'package:remind_me/models/contact_model.dart';

class ContactDetailsArgs {
  const ContactDetailsArgs({
    required this.contact,
    this.selectedEvent,
  });

  final ContactModel contact;
  final ContactEvent? selectedEvent;
}
