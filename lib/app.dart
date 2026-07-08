import 'package:flutter/material.dart';
import 'package:remind_me/core/theme/app_theme.dart';
import 'package:remind_me/core/utils/app_router.dart';

class RemindMeApp extends StatelessWidget {
  const RemindMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Remind Me',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
