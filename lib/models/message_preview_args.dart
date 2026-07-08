import 'package:remind_me/models/contact_model.dart';
import 'package:remind_me/models/event_type.dart';

class MessagePreviewArgs {
  const MessagePreviewArgs({
    required this.contact,
    required this.eventType,
    required this.styleLabel,
    required this.templateKey,
    required this.initialMessage,
  });

  final ContactModel contact;
  final EventType eventType;
  final String styleLabel;
  final String templateKey;
  final String initialMessage;
}
