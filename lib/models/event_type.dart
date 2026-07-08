import 'package:flutter/material.dart';

enum EventType {
  birthday,
  anniversary,
  other;

  String get label {
    return switch (this) {
      EventType.birthday => 'Birthday',
      EventType.anniversary => 'Anniversary',
      EventType.other => 'Event',
    };
  }

  String displayLabel({String? customLabel}) {
    if (this == EventType.other &&
        customLabel != null &&
        customLabel.trim().isNotEmpty) {
      return customLabel.trim();
    }
    return label;
  }

  IconData get icon {
    return switch (this) {
      EventType.birthday => Icons.cake_rounded,
      EventType.anniversary => Icons.favorite_rounded,
      EventType.other => Icons.event_rounded,
    };
  }
}
