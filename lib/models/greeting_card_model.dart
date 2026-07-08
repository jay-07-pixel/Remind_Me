import 'package:remind_me/core/constants/message_template_catalog.dart';

class GreetingCardModel {
  const GreetingCardModel({
    required this.id,
    required this.assetPath,
    required this.section,
  });

  final String id;
  final String assetPath;
  final MessageTemplateSection section;
}
