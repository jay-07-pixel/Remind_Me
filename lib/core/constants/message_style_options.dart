import 'package:remind_me/models/event_type.dart';

class MessageStyleOption {
  const MessageStyleOption({
    required this.templateKey,
    required this.label,
    required this.emoji,
  });

  final String templateKey;
  final String label;
  final String emoji;
}

abstract final class MessageStyleOptions {
  static const birthday = <MessageStyleOption>[
    MessageStyleOption(
      templateKey: 'birthday_formal',
      label: 'Formal',
      emoji: '🎉',
    ),
    MessageStyleOption(
      templateKey: 'birthday_funny',
      label: 'Funny',
      emoji: '😂',
    ),
    MessageStyleOption(
      templateKey: 'birthday_emotional',
      label: 'Emotional',
      emoji: '❤️',
    ),
    MessageStyleOption(
      templateKey: 'birthday_short',
      label: 'Short',
      emoji: '✨',
    ),
  ];

  static const anniversary = <MessageStyleOption>[
    MessageStyleOption(
      templateKey: 'anniversary_romantic',
      label: 'Romantic',
      emoji: '❤️',
    ),
    MessageStyleOption(
      templateKey: 'anniversary_friendly',
      label: 'Friendly',
      emoji: '😊',
    ),
    MessageStyleOption(
      templateKey: 'anniversary_classic',
      label: 'Classic',
      emoji: '🎊',
    ),
    MessageStyleOption(
      templateKey: 'anniversary_professional',
      label: 'Professional',
      emoji: '🙏',
    ),
  ];

  static List<MessageStyleOption> forEventType(EventType eventType) {
    return switch (eventType) {
      EventType.birthday => birthday,
      EventType.anniversary => anniversary,
      EventType.other => const [],
    };
  }
}
