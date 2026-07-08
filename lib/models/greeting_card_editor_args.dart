import 'package:remind_me/core/constants/message_template_catalog.dart';
import 'package:remind_me/models/contact_model.dart';
import 'package:remind_me/models/greeting_card_model.dart';

class GreetingCardEditorArgs {
  const GreetingCardEditorArgs({
    required this.contact,
    required this.card,
    required this.style,
    required this.templateText,
  });

  final ContactModel contact;
  final GreetingCardModel card;
  final MessageTemplateOption style;
  final String templateText;
}
