import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remind_me/widgets/placeholder_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Settings',
      subtitle: 'Settings screen placeholder',
      icon: Icons.settings_outlined,
      actions: [
        OutlinedButton(
          onPressed: () => context.pop(),
          child: const Text('Back'),
        ),
      ],
    );
  }
}
