enum MessageTemplateSection {
  birthday('Birthday Templates'),
  anniversary('Anniversary Templates');

  const MessageTemplateSection(this.title);
  final String title;
}

class MessageTemplateOption {
  const MessageTemplateOption({
    required this.key,
    required this.section,
    required this.category,
    required this.defaultTemplate,
  });

  final String key;
  final MessageTemplateSection section;
  final String category;
  final String defaultTemplate;
}

abstract final class MessageTemplateCatalog {
  static const options = <MessageTemplateOption>[
    MessageTemplateOption(
      key: 'birthday_formal',
      section: MessageTemplateSection.birthday,
      category: 'Formal',
      defaultTemplate:
          'Dear {name}, wishing you a very Happy Birthday. May this year bring you success, health, and happiness.',
    ),
    MessageTemplateOption(
      key: 'birthday_funny',
      section: MessageTemplateSection.birthday,
      category: 'Funny',
      defaultTemplate:
          'Happy Birthday {name}! You are not getting older, just becoming a limited-edition classic.',
    ),
    MessageTemplateOption(
      key: 'birthday_emotional',
      section: MessageTemplateSection.birthday,
      category: 'Emotional',
      defaultTemplate:
          'Happy Birthday {name}. Grateful for your presence in my life and wishing you endless joy and love.',
    ),
    MessageTemplateOption(
      key: 'birthday_short',
      section: MessageTemplateSection.birthday,
      category: 'Short',
      defaultTemplate: 'Happy Birthday {name}! Have an amazing day.',
    ),
    MessageTemplateOption(
      key: 'anniversary_romantic',
      section: MessageTemplateSection.anniversary,
      category: 'Romantic',
      defaultTemplate:
          'Happy Anniversary {name}! Wishing you both a lifetime of love, laughter, and beautiful memories.',
    ),
    MessageTemplateOption(
      key: 'anniversary_friendly',
      section: MessageTemplateSection.anniversary,
      category: 'Friendly',
      defaultTemplate:
          'Happy Anniversary {name}! Hope your special day is full of smiles and celebration.',
    ),
    MessageTemplateOption(
      key: 'anniversary_classic',
      section: MessageTemplateSection.anniversary,
      category: 'Classic',
      defaultTemplate:
          'Wishing you a very Happy Anniversary, {name}. May your journey together remain joyful and blessed.',
    ),
    MessageTemplateOption(
      key: 'anniversary_professional',
      section: MessageTemplateSection.anniversary,
      category: 'Professional',
      defaultTemplate:
          'Congratulations on your anniversary, {name}. Wishing you continued happiness and togetherness.',
    ),
  ];

  static Map<String, String> defaultTemplatesMap() {
    return {
      for (final option in options) option.key: option.defaultTemplate,
    };
  }
}
