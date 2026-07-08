import 'package:remind_me/core/constants/message_template_catalog.dart';
import 'package:remind_me/models/greeting_card_model.dart';

class GreetingCardPreviewArgs {
  const GreetingCardPreviewArgs({
    required this.card,
    required this.style,
    required this.toName,
    required this.fromName,
    required this.message,
    required this.phoneNumber,
  });

  final GreetingCardModel card;
  final MessageTemplateOption style;
  final String toName;
  final String fromName;
  final String message;
  final String? phoneNumber;
}
