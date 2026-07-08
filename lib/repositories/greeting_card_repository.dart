import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:remind_me/core/constants/message_template_catalog.dart';
import 'package:remind_me/models/greeting_card_model.dart';

class GreetingCardRepository {
  const GreetingCardRepository();

  Future<List<GreetingCardModel>> getCards(MessageTemplateSection section) async {
    final manifest = await rootBundle.loadString('AssetManifest.json');
    final map = jsonDecode(manifest) as Map<String, dynamic>;

    final folder = switch (section) {
      MessageTemplateSection.birthday => 'assets/cards/birthday/',
      MessageTemplateSection.anniversary => 'assets/cards/anniversary/',
    };

    final entries = map.keys
        .where((path) => path.startsWith(folder))
        .where((path) => path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.webp'))
        .toList()
      ..sort();

    return entries
        .map(
          (path) => GreetingCardModel(
            id: path.replaceAll('/', '_'),
            assetPath: path,
            section: section,
          ),
        )
        .toList();
  }
}
