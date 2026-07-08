import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remind_me/widgets/placeholder_screen.dart';

class TodayEventsScreen extends StatelessWidget {
  const TodayEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: "Today's Events",
      subtitle: "Today's events screen placeholder",
      icon: Icons.event_outlined,
      actions: [
        OutlinedButton(
          onPressed: () => context.pop(),
          child: const Text('Back'),
        ),
      ],
    );
  }
}
